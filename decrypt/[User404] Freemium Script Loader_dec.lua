return (function(Z, M, z, i, n, o, x, N, Y, G, g, t, v, E, I, d, k, m, B, p, q, e)
  I, k, t, Y, e, v, m, N, p, G, q, B, d, g, E =
    function(x)
      local L, B = 1, x[1]
      while B do
        d[B], L = d[B] - 1, 1 + L
        if d[B] == 0 then
          d[B], Y[B] = nil, nil
        end
        B = x[L]
      end
    end, function(x)
      d[x] = d[x] - 1
      if d[x] == 0 then
        d[x], Y[x] = nil, nil
      end
    end, function(x)
      for L = 1, #x, 1 do
        d[x[L]] = d[x[L]] + 1
      end
      if Z then
        local B = Z(true)
        local o = i(B)
        o["__index"], o["__gc"], o["__len"] = x, I, function()
          return -1224065
        end
        return B
      else
        return M({}, {
          ["__gc"] = I,
          ["__index"] = x,
          ["__len"] = function()
            return -1224065
          end,
        })
      end
    end, {}, function(x, L)
      local o = t(L)
      local Z = function(...)
        return B(x, { ... }, L, o)
      end
      return Z
    end, function(x, L)
      local o = t(L)
      local Z = function(Z, M, i, n, z, Y)
        return B(x, { Z, M, i, n, z, Y }, L, o)
      end
      return Z
    end, function(x, L)
      local o = t(L)
      local Z = function(Z, M, i, n, z)
        return B(x, { Z, M, i, n, z }, L, o)
      end
      return Z
    end, 0, function(x, L)
      local o = t(L)
      local Z = function(Z)
        return B(x, { Z }, L, o)
      end
      return Z
    end, function(x, L)
      local o = t(L)
      local Z = function()
        return B(x, {}, L, o)
      end
      return Z
    end, function(x, L)
      local o = t(L)
      local Z = function(Z, M, i, n)
        return B(x, { Z, M, i, n }, L, o)
      end
      return Z
    end, function(B, Z, M, i)
      local C, c, a, B9, J, f, O, F, S, Z9, s, Q, L9, D, o9, w, U, z, l, j, x9, t, h, y, K, R, d, A, b, I, r, u, T, H, X, P, N, V, W, e
      while B do
        if 9192155 > B then
          if 4736727 > B then
            if B > 2844028 then
              if B > 4129147 then
                if B < 4343501 then
                  if B < 4188219 then
                    z, f = 0, t
                    B = f == z
                    B = B and 7161799 or 1547102
                  elseif B < 4206904 then
                    B = 10856143
                  elseif B < 4231979 then
                    B = 12394992
                    N = Y[M[2]]
                    t = Y[M[3]]
                    d = N == t
                    z = d
                  else
                    c, e, B = "pcall", "string", 5247510 <= 12061117
                    Y[N] = B
                    I = x[e]
                    e = "gmatch"
                    t = I[e]
                    f = B
                    I = g()
                    Y[I] = t
                    t = m(7307533, {})
                    e = g()
                    Y[e] = t
                    H = g()
                    t = 2287444 <= 757582
                    Y[H] = t
                    F = x[c]
                    W = p(5242591, { H })
                    c = F(W)
                    B, t = c and 8265384 or 5751301, c
                  end
                else
                  if B < 4515544 then
                    O = O + u
                    K, A = O <= D, not l
                    K = A and K
                    A = O >= D
                    A = l and A
                    K = A or K
                    A = 14575951
                    B = K and A
                    K = 13792559
                    B = B or K
                  elseif B < 4642621 then
                    r = 5
                    U = f == r
                    B = U and 4701151 or 10098297
                  elseif 4712332 > B then
                    r = Y[N]
                    b = 13460079 < 5363078
                    U = r == b
                    B = U and 4189855 or 4982403
                  else
                    B = 730874
                  end
                end
              else
                if 3313602 > B then
                  if B < 2913826 then
                    r = 8840459 < 4333967
                    Y[N] = r
                    B = 6799726
                  elseif B < 2999210 then
                    B = 9654055 > 4239786
                    B = B and 10520392 or 13883007
                  elseif 3087421 > B then
                    d = "error"
                    B = x[d]
                    t = 0
                    N = Y[M[8]]
                    d = B(N, t)
                    B = 4071710
                  else
                    B = 10856143
                  end
                else
                  if B < 3593582 then
                    l = "l2"
                    h = x[l]
                    B, l = 14651421, "l1"
                    x[l] = h
                  elseif B < 3674071 then
                    c, B = s, K
                    B = s and 2192421 or 10558793
                  elseif B < 3881450 then
                    B = 12327828
                  else
                    t = Y[M[9]]
                    B = {}
                    d, I = B, t
                    t = 1
                    e = t
                    t = 0
                    H, B, N = t > e, 1324527, 1
                    t = N - e
                  end
                end
              end
            else
              if 1522403 > B then
                if B > 746778 then
                  if 869834 > B then
                    Y[N] = w
                    B = h
                    h = Y[N]
                    B = h and 8312655 or 11842556
                  elseif B < 1150756 then
                    j = "tostring"
                    h = x[j]
                    A, B = "l1", 14651421
                    l = x[A]
                    j = h(l)
                    h = "l2"
                    x[h] = j
                  elseif B < 1417590 then
                    f, t = not H, e + t
                    N = t <= I
                    N = f and N
                    f = t >= I
                    f = H and f
                    N = f or N
                    f = 4844068
                    B = N and f
                    N = 5961602
                    B = B or N
                  else
                    L9 = 1
                    Y[N] = Q
                    o9 = Y[C]
                    B = Z9
                    x9 = o9 + L9
                    R = a[x9]
                    P = s + R
                    R = 256
                    Z9 = P % R
                    x9 = Y[J]
                    s = Z9
                    R = K + x9
                    B, x9 = 1534153, 256
                    P = R % x9
                    K = P
                  end
                else
                  if 292893 > B then
                    O = nil
                    I = k(I)
                    s = nil
                    N = k(N)
                    D, f = nil, nil
                    F = k(F)
                    H = k(H)
                    W = k(W)
                    O, t, N = "string", nil, nil
                    c = k(c)
                    K = nil
                    f = g()
                    t = nil
                    e = k(e)
                    u = k(u)
                    H = "table"
                    e = x[H]
                    H = "remove"
                    I = e[H]
                    e = 2
                    H = g()
                    Y[H] = e
                    s, W, e = "math", "math", {}
                    Y[f] = e
                    e = {}
                    c = x[W]
                    W = "random"
                    F = c[W]
                    B = 4446998
                    W = x[s]
                    s = "floor"
                    c = W[s]
                    W = g()
                    s = g()
                    Y[W] = c
                    c = 0
                    Y[s] = c
                    K = x[O]
                    O = "char"
                    c = K[O]
                    K, O = 1, 256
                    D = O
                    O = 1
                    u = O
                    O = 0
                    l = u < O
                    O = K - u
                  elseif B < 564310 then
                    B = 14613873
                  elseif 681564 > B then
                    h = B
                    y = Y[N]
                    w, B = y, y and 9375826 or 762683
                  else
                    B = 6799726
                  end
                end
              else
                if B < 2006723 then
                  if B < 1540627 then
                    J = k(J)
                    w = k(w)
                    T = k(T)
                    A = k(A)
                    S = k(S)
                    a, B = nil, 13630760
                    C = k(C)
                  elseif B < 1679235 then
                    V = 1
                    z = f == V
                    B = z and 13525025 or 8623163
                  elseif B < 1816197 then
                    B, z = x["flEHwqGXx0jV"], { N }
                  else
                    B, U = 6799726, 15887694 >= 6050946
                    Y[N] = U
                  end
                else
                  if B < 2447743 then
                    B, O = W, 65
                    w = E(12783136, {})
                    W = g()
                    K, l, B = 3, "tostring", 13630760
                    Y[W] = c
                    c = Y[F]
                    s = c(K, O)
                    c = g()
                    Y[c] = s
                    u, s = "pcall", 0
                    K = 0
                    D = x[u]
                    u = { D(w) }
                    O = { o(u) }
                    w, u = "tonumber", 2
                    D = O[u]
                    u = x[w]
                    h = Y[I]
                    j = x[l]
                    l = j(D)
                    j = ":(%d*):"
                    y = h(l, j)
                    h = { y() }
                    w = u(o(h))
                    u = g()
                    Y[u] = w
                    h = Y[c]
                    w, y = 1, h
                    h = 1
                    j = h
                    h = 0
                    l = h > j
                    h = w - j
                  elseif B < 2725337 then
                    N = Y[M[3]]
                    t = 75
                    d = N * t
                    N = 257
                    z = d % N
                    t = 1
                    Y[M[3]] = z
                    N = Y[M[3]]
                    d = N ~= t
                    B = d and 14324906 or 2703065
                  elseif 2764293 > B then
                    B = Q
                    Y[N] = X
                    B = 1534153
                  else
                    B = x["46xBltw7YmDp"]
                    h = E(9767387, { e })
                    y = { h() }
                    z = { o(y) }
                  end
                end
              end
            end
          else
            if B < 6742509 then
              if B > 5606579 then
                if B < 6174587 then
                  if 5748180 > B then
                    R = 1
                    P = a[R]
                    B, Q = 1510654, P
                  elseif B < 5856451 then
                    c = "math"
                    F = x[c]
                    B, W, c = f, "table", "random"
                    K = B
                    f = F[c]
                    F = g()
                    Y[F] = f
                    c = x[W]
                    W = "concat"
                    f = c[W]
                    D, W = "table", B
                    O = x[D]
                    B, s = O and 4749942 or 3656952, O
                  elseif B < 6054011 then
                    B = Y[M[10]]
                    N = Y[M[11]]
                    d[B] = N
                    B = Y[M[12]]
                    N = { B(d) }
                    B, z = x["mqrD41xjnabT65"], { o(N) }
                  else
                    u, B = "string", 5044687
                    D = x[u]
                    u, U = "byte", b
                    O = D[u]
                    D = O(d, U)
                    U = nil
                    O = Y[M[6]]
                    u = O()
                    K = D + u
                    s = K + f
                    D, K = 1, 256
                    W = s % K
                    f = W
                    O = f + D
                    K = I[O]
                    s = V .. K
                    V = s
                  end
                else
                  if 6276534 > B then
                    B = 6799726
                  elseif B < 6391034 then
                    B = 7825619
                  elseif B < 6558522 then
                    j, l = 1, 6
                    h = Y[F]
                    y = h(j, l)
                    h, l = "l2", "l2"
                    x[h] = y
                    j = x[l]
                    l = 2
                    h = j > l
                    B = h and 976985 or 3530212
                  else
                    N = Y[M[1]]
                    d = #N
                    t = Y[M[1]]
                    N = t[d]
                    I = nil
                    t = Y[M[1]]
                    t[d] = I
                    z, B = { N }, x["bnzytSvKLSLz"]
                  end
                end
              else
                if B < 5073277 then
                  if B < 4797005 then
                    u, B = "table", 3656952
                    D = x[u]
                    u = "unpack"
                    O = D[u]
                    s = O
                  elseif 4913235 > B then
                    V = 0
                    B = Y[M[1]]
                    N, U = t, 255
                    f = B(V, U)
                    B = 1324527
                    d[N] = f
                    N = nil
                  elseif B < 5013545 then
                    B = 7825619
                  else
                    b = F + b
                    U, W = r >= b, not c
                    U = W and U
                    W = b >= r
                    W = c and W
                    U = W or U
                    W = 6146421
                    B = U and W
                    U = 16000999
                    B = B or U
                  end
                else
                  if 5172229 > B then
                    B = 730874
                  elseif 5312131 > B then
                    B, z = 15113012 ~= 1515639, {}
                    Y[M[1]] = B
                    B = x["GlA9fNPChOyo"]
                  elseif B < 5424884 then
                    B = 6799726
                  else
                    P, o9 = B, 1
                    x9 = a[o9]
                    o9 = 11989717 < 5689701
                    R = x9 == o9
                    B, Z9 = R and 10867277 or 14401654, R
                  end
                end
              end
            else
              if 8207225 > B then
                if B < 7131264 then
                  if 6824780 > B then
                    B, f = 15979333, nil
                  elseif B < 6879347 then
                    U, B = 1, {}
                    Y[M[2]] = B
                    z = Y[M[3]]
                    I, e = z, 35184372088832
                    z = N % e
                    Y[M[4]] = z
                    f = 255
                    H = N % f
                    f, V = 2, ""
                    e = H + f
                    B = 5044687
                    Y[M[5]] = e
                    H = #d
                    b, r, f = 1, H, ""
                    F = b
                    t[N] = f
                    b, f = 0, 218
                    c = b > F
                    b = U - F
                  elseif 7004795 > B then
                    B = 11206340 <= 11103239
                    Y[N] = B
                    B = 6799726
                  else
                    w = g()
                    X = 1
                    Y[w] = h
                    R, C = "tostring", "math"
                    J = x[C]
                    B9, C, a = 10000, "random", 100
                    A = J[C]
                    C = 1
                    J = A(C, a)
                    a, Q = 0, 2
                    A = g()
                    T = 255
                    Y[A] = J
                    J = Y[F]
                    C = J(a, T)
                    J = g()
                    T = 1
                    Y[J] = C
                    C = Y[F]
                    S = Y[A]
                    a = C(T, S)
                    C = g()
                    Y[C] = a
                    T = Y[F]
                    S = T(X, Q)
                    T = 1
                    a = S == T
                    T = g()
                    Y[T] = a
                    L9, a, Q = 0, "gsub", ":"
                    P = x[R]
                    S = ":(%d*):"
                    x9 = Y[F]
                    a = D[a]
                    o9 = { x9(L9, B9) }
                    R = P(o(o9))
                    P = ":"
                    Z9 = R .. P
                    X = Q .. Z9
                    a = a(D, S, X)
                    S = g()
                    Z9 = q(15793528, { F, w, c, I, N, u, T, S, A, C, J, W })
                    Q = "pcall"
                    Y[S] = a
                    X = x[Q]
                    Q = { X(Z9) }
                    a = { o(Q) }
                    X = Y[T]
                    B = X and 14844090 or 10103428
                  end
                else
                  if B < 7234666 then
                    z = Y[N]
                    V = "bfW5iqehLe8reGA"
                    B = z ~= V
                    B = B and 11783863 or 6908861
                  elseif 7566576 > B then
                    z = "error"
                    B = x[z]
                    d = "Tamper Detected!"
                    z = B(d)
                    z, B = {}, x["GHY7r7VAP8Mq"]
                  elseif 8007238 > B then
                    U = 13637546 ~= 15265292
                    B = U and 6350316 or 3096993
                  else
                    B = 6202753
                  end
                end
              else
                if B < 8551254 then
                  if B < 8245488 then
                    B = Y[M[7]]
                    B = B and 3077849 or 4071710
                  elseif 8289019 > B then
                    F = Y[H]
                    t, B = F, 5751301
                  elseif 8396000 > B then
                    B = 89421
                  else
                    B = 14613873
                  end
                else
                  if B < 8690623 then
                    V = 2
                    z = f == V
                    B = z and 13437187 or 13402682
                  elseif B < 8909537 then
                    b, B = 13924700 < 6684703, 6799726
                    Y[N] = b
                  else
                    D = #e
                    A, O = 1, 1
                    K = F(O, D)
                    O = I(e, K)
                    D = Y[f]
                    l = O - A
                    u = c(l)
                    D[O] = u
                    l, K = 0, nil
                    u = #e
                    D = u == l
                    O, B = nil, D and 9410368 or 9060991
                  end
                end
              end
            end
          end
        else
          if 12505046 > B then
            if 10827114 > B then
              if B < 10100862 then
                if B > 9393097 then
                  if B < 9554068 then
                    l, K = "setmetatable", {}
                    u = g()
                    S = nil
                    O = g()
                    D = G(10676098, { O, s, H, W })
                    Y[O] = K
                    K = g()
                    W = k(W)
                    F = nil
                    Y[K] = D
                    D, T, c, A, W = {}, "__metatable", nil, {}, "D\2457\233\157Hu\157\235C\245F\022\160B\150\133\133\235j\225\233U\211_\223D4\202\023\199e\206\136"
                    Y[u] = D
                    D = x[l]
                    a = Y[u]
                    C, I = "__index", nil
                    J = { [C] = a, [T] = S }
                    l = D(A, J)
                    D = v(12556688, { u, O, f, s, H, K })
                    t = D
                    f = k(f)
                    u = k(u)
                    s = k(s)
                    z = {}
                    H = k(H)
                    s = 10906654600404
                    K = k(K)
                    O = k(O)
                    N, e, f = l, nil, "fetch"
                    e = "load"
                    I = x[e]
                    H = x[f]
                    c = t(W, s)
                    F = N[c]
                    t = nil
                    f = { H(F) }
                    B = x["EWoAT1DTLYY2NP"]
                    e = I(o(f))
                    I = e()
                    N = nil
                  elseif 9732577 > B then
                    B = 9337505
                  elseif 9932842 > B then
                    B = 11311057
                  else
                    r = 6
                    U = f == r
                    B = U and 1821026 or 15535131
                  end
                else
                  if 9330412 > B then
                    B = 13586010
                  elseif 9344408 > B then
                    B = 6799726
                  elseif B < 9363568 then
                    t = 10
                    I, d = t, Z
                    N = g()
                    z, t, B = 0, 1, "bfW5iqehLe8reGA"
                    Y[N] = B
                    e = t
                    t = 0
                    H = e < t
                    t, B = z - e, 15979333
                  else
                    y = s == K
                    B, w = 762683, y
                  end
                end
              else
                if 10617445 > B then
                  if B < 10259063 then
                    Z9 = B
                    P = Y[N]
                    B, Q = P and 5745060 or 1510654, P
                  elseif 10467545 > B then
                    F = 10
                    b = f == F
                    B = b and 8758083 or 6799726
                  elseif B < 10539592 then
                    B = 2920572
                  else
                    K = "unpack"
                    s = x[K]
                    c, B = s, 2192421
                  end
                else
                  if B < 10701981 then
                    d = Y[M[1]]
                    z = #d
                    d = 0
                    B = z == d
                    B = B and 12179757 or 6685292
                  elseif 10742812 > B then
                    b = 8
                    r = f == b
                    B = r and 2907080 or 15474331
                  elseif B < 10777922 then
                    b = Y[N]
                    F = 6017267 > 2736481
                    r = b == F
                    B = r and 4723513 or 11696443
                  else
                    B = 12327828
                  end
                end
              end
            else
              if B < 11641815 then
                if B < 11195737 then
                  if 10861710 > B then
                    B = 6799726
                  elseif 10879079 > B then
                    o9 = 2
                    x9 = a[o9]
                    o9 = Y[S]
                    R = x9 == o9
                    B, Z9 = 14401654, R
                  elseif B < 11034649 then
                    d = nil
                    Y[M[5]] = z
                    B = 8225592
                  else
                    B = 6202753
                  end
                else
                  if B < 11262056 then
                    B, z = x["xcLJ2DHZz6K5Gp"], { N }
                  elseif 11365804 > B then
                    B = 9701329 <= 10084056
                    B = B and 11420552 or 14702920
                  elseif 11503870 > B then
                    z = "l2"
                    B = x[z]
                    d = "l1"
                    z = x[d]
                    d = "l1"
                    x[d] = B
                    d = "l2"
                    x[d] = z
                    d = Y[M[1]]
                    B = 11311057
                    N = d()
                  else
                    U = Y[N]
                    r = 8794693 < 1450879
                    V = U == r
                    B = V and 8188858 or 10798086
                  end
                end
              else
                if B < 12253792 then
                  if 11740153 > B then
                    B = 13193055
                  elseif B < 11813209 then
                    B = 2920572
                  elseif 12011156 > B then
                    B = 2780977
                  else
                    t = 21
                    N = Y[M[2]]
                    d = N * t
                    N = 18576417235845
                    z = d + N
                    d = 35184372088832
                    B = z % d
                    Y[M[2]] = B
                    B = 2703065
                  end
                else
                  if B < 12361410 then
                    V = 8387580 ~= 11244112
                    B = V and 3691191 or 11178418
                  elseif B < 12424198 then
                    B = z and 15955478 or 8225592
                  else
                    B = 13193055
                  end
                end
              end
            end
          else
            if 14363280 > B then
              if B > 13573344 then
                if 13871782 > B then
                  if B < 13608385 then
                    h = 11654686 <= 11744251
                    B = h and 6431753 or 13560679
                  elseif B < 13711659 then
                    A, h = not l, h + j
                    w = y >= h
                    w = A and w
                    A = h >= y
                    A = l and A
                    w = A or w
                    A = 7100729
                    B = w and A
                    w = 632254
                    B = B or w
                  elseif 13826558 > B then
                    B = 9060991
                  else
                    c = 12990946 < 8239712
                    F = Y[N]
                    b = F == c
                    B = b and 9697768 or 8479345
                  end
                else
                  if B < 13946187 then
                    B = 6908861
                  elseif 14058853 > B then
                    U = 4
                    V = f == U
                    B = V and 16761397 or 4584091
                  elseif B < 14216622 then
                    t = Y[M[6]]
                    N = t == d
                    B, z = 10890881, N
                  else
                    N = Y[M[3]]
                    t = 32
                    d = N % t
                    t, r, F = 13, 2, 256
                    H = Y[M[3]]
                    e = H - d
                    H = 32
                    I = e / H
                    N = t - I
                    e = Y[M[4]]
                    V = Y[M[2]]
                    U = r ^ N
                    f = V / U
                    U = 1
                    H = e(f)
                    e = 4294967296
                    I = H % e
                    H = 2
                    e = H ^ d
                    N = nil
                    t = I / e
                    B = 6685292
                    e = Y[M[4]]
                    V = t % U
                    U = 4294967296
                    f = V * U
                    H = e(f)
                    e = Y[M[4]]
                    f = e(t)
                    U, W = 256, 256
                    I = H + f
                    H, d, t = 65536, nil, nil
                    V = 65536
                    e = I % H
                    f = I - e
                    H = f / V
                    V = e % U
                    b = e % F
                    r = e - b
                    b = 256
                    U = r / b
                    b = 256
                    r = H % b
                    e = nil
                    c = H % W
                    F = H - c
                    c = 256
                    b = F / c
                    f = { V, U, r, b }
                    Y[M[1]] = f
                    I, H = nil, nil
                  end
                end
              else
                if 13419934 > B then
                  if 12669912 > B then
                    N = Z[2]
                    B = Y[M[1]]
                    d, t = Z[1], B
                    B = t[N]
                    B = B and 11213056 or 6849834
                  elseif 12988095 > B then
                    z, t, N = 14993550, 7750008, "MSEhcVWgGoCzCC"
                    d = N ^ t
                    B = z - d
                    z, d = "WHdq", B
                    B = z / d
                    z = { B }
                    B = x["vDY14mQGdrDq"]
                  elseif B < 13297868 then
                    r = 6175137 >= 2545473
                    B = r and 12453405 or 5101867
                  else
                    U = 3
                    V = f == U
                    B = V and 11587188 or 14009368
                  end
                else
                  if B < 13458260 then
                    z = 3395550 >= 5253956
                    Y[N] = z
                    B = 6799726
                  elseif B < 13502179 then
                    B = 5381671
                  elseif B < 13542852 then
                    U = 11508956 <= 10583487
                    V = Y[N]
                    z = V == U
                    B = z and 13479334 or 5381671
                  else
                    z, B = {}, x["ZP6J5wkn2qxBA"]
                  end
                end
              end
            else
              if B > 15664329 then
                if 16013831 > B then
                  if B < 15874503 then
                    N = Y[M[1]]
                    e, I = 2, 1
                    t = N(I, e)
                    N = 1
                    d = t == N
                    z, B = d, d and 12394992 or 4223954
                  elseif B < 15967405 then
                    V, z = "pcall", "tonumber"
                    B = x[z]
                    I = "tostring"
                    U = q(16026664, {})
                    d = Y[M[4]]
                    t = x[I]
                    f = x[V]
                    V = { f(U) }
                    f, H = 2, { o(V) }
                    e = H[f]
                    I = t(e)
                    t = ":(%d*):"
                    N = d(I, t)
                    d = { N() }
                    z = B(o(d))
                    N = Y[M[5]]
                    d = z
                    z, B = N, N and 14108338 or 10890881
                  elseif 15990166 > B then
                    f, t = not H, e + t
                    z = t <= I
                    z = f and z
                    f = t >= I
                    f = H and f
                    z = f or z
                    f = 4186584
                    B = z and f
                    z = 4240004
                    B = B or z
                  else
                    B, I, U, f = 1811368, nil, V, nil
                    t[N] = U
                    V, H = nil, nil
                  end
                else
                  if B < 16236940 then
                    z, N, t = 2432251, "QODWB6r1tqIEBgg", 8241785
                    d = N ^ t
                    B = z - d
                    z, d = "cz", B
                    B = z / d
                    z = { B }
                    B = x["ckoaB8EQ3jyAFG"]
                  elseif B < 16604307 then
                    B = 9337505
                  else
                    V = 5129910 > 5240995
                    Y[N] = V
                    B = 6799726
                  end
                end
              else
                if B < 14677170 then
                  if 14488802 > B then
                    B = P
                    B, X = 2747610, Z9
                  elseif 14594912 > B then
                    B, K = 4446998, O
                    A = K
                    e[K] = A
                    K = nil
                  elseif B < 14632647 then
                    b = 3779786 < 12570979
                    B = b and 496366 or 16447217
                  else
                    B = 13586010
                  end
                else
                  if B < 14773505 then
                    B, z = x["keyNTG44Vz2T9"], {}
                  elseif B < 15159210 then
                    Q = B
                    Z9 = Y[N]
                    B, X = Z9 and 5468098 or 2747610, Z9
                  elseif 15504731 > B then
                    F = 9
                    b = f == F
                    B = b and 13860557 or 10414698
                  else
                    b = 7
                    r = f == b
                    B = r and 10757759 or 10727865
                  end
                end
              end
            end
          end
        end
      end
      B = #i
      return o(z)
    end, {}, function()
      N = 1 + N
      d[N] = 1
      return N
    end, function(x, L)
      local o = t(L)
      local Z = function(Z, M)
        return B(x, { Z, M }, L, o)
      end
      return Z
    end
  return (e(9351311, {}))(o(z))
end)(newproxy, setmetatable, { ... }, getmetatable, select, unpack or table["unpack"], getfenv and getfenv() or _ENV)
