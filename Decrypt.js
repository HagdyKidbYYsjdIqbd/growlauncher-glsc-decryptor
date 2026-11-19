// huh?, https://growlauncher.powerkuy.dev

const crypto = require("crypto");
const fs = require("fs");

function ExtractKeyAndCiphertext(bufBody) {
  const nLen = bufBody.length;
  if (nLen < 32) throw new Error("body(size) is to small");

  const bufKey = Buffer.alloc(32);
  const bufCipher = Buffer.alloc(nLen - 32);
  const arrKeyPos = new Uint32Array(32);

  for (let i = 0; i < 32; i++) arrKeyPos[i] = Math.floor((nLen * i) / 32);

  let iKIdx = 0;
  let iCIdx = 0;

  for (let i = 0; i < nLen; i++) {
    if (iKIdx < 32 && i === arrKeyPos[iKIdx]) {
      bufKey[iKIdx++] = bufBody[i];
    } else {
      bufCipher[iCIdx++] = bufBody[i];
    }
  }

  return { bufKey, bufCipher };
}

function BuildInvSbox(bufKey) {
  const arrSbox = new Uint8Array(256);
  for (let i = 0; i < 256; i++) arrSbox[i] = i;

  let j = 0;
  for (let i = 0; i < 256; i++) {
    j = (j + arrSbox[i] + bufKey[i & 31]) & 0xff;
    const byTmp = arrSbox[i];
    arrSbox[i] = arrSbox[j];
    arrSbox[j] = byTmp;
  }

  const arrInv = new Uint8Array(256);
  for (let i = 0; i < 256; i++) arrInv[arrSbox[i]] = i;
  return arrInv;
}

function BuildPerm(bufKeySched) {
  const arrPerm = new Uint8Array([0, 1, 2, 3, 4, 5, 6, 7]);
  for (let i = 7; i > 0; i--) {
    const j = bufKeySched[i] % (i + 1);
    const byTmp = arrPerm[i];
    arrPerm[i] = arrPerm[j];
    arrPerm[j] = byTmp;
  }
  return arrPerm;
}

function BuildBitPermLut(arrPerm) {
  const arrLut = new Uint8Array(256);
  for (let v = 0; v < 256; v++) {
    let byRes = 0;
    for (let k = 0; k < 8; k++) {
      if ((v >>> arrPerm[k]) & 1) byRes |= 1 << k;
    }
    arrLut[v] = byRes;
  }
  return arrLut;
}

function DecryptGlscV2(bufData) {
  if (
    bufData.length < 37 ||
    bufData.subarray(0, 4).toString("ascii") !== "GLSC" ||
    bufData[4] !== 0x02
  ) throw new Error("header not valid or is not v2");

  const { bufKey, bufCipher } = ExtractKeyAndCiphertext(bufData.subarray(5));
  const bufKeySched = crypto.createHash("sha256").update(bufKey).digest();
  const arrInvSbox = BuildInvSbox(bufKey);
  const arrBitPermLut = BuildBitPermLut(BuildPerm(bufKeySched));

  const nLen = bufCipher.length;
  const bufOut = Buffer.alloc(nLen);
  let byPrev = bufKey[0];

  for (let i = 0; i < nLen; i++) {
    const byC = bufCipher[i];
    let byB = arrInvSbox[byC];
    byB = (byB - byPrev - i) & 0xff;
    byB ^= bufKey[(i + 7) & 31];
    byB = arrBitPermLut[byB];

    const byKs = bufKeySched[i & 31];
    const iShift = (byKs & 6) !== 0 ? byKs & 7 : 1;
    byB = ((byB >>> iShift) | (byB << ((8 - iShift) & 7))) & 0xff;

    bufOut[i] = arrInvSbox[byB];
    byPrev = byC;
  }

  return bufOut;
}

const szInputPath = process.argv[2];
const szOutputPath = process.argv[3];

if (!szInputPath) {
  console.error("Usage: node dec.js <input.lua> [output.lua]");
  process.exit(1);
}

const bufRaw = fs.readFileSync(szInputPath);
const bufPlain = DecryptGlscV2(bufRaw);

if (szOutputPath) {
  fs.writeFileSync(szOutputPath, bufPlain);
  console.log(`Saved: ${szOutputPath} (${bufPlain.length} bytes)`);
}
