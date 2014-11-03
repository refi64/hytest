(require hytest)

(test-set test-setup-and-teardown
  (test-setup
    (def x 0)
    (def y 1))
  (test-teardown
    (def x 1)
    (def y 2))
  (test = x 0)
  (test = y 1))

(test-set test-skip
  (test raises-msg "skipthis" (skip-test "skipthis")))

(test-set test-fails
  (test raises-msg "failthis" (fail-test "failthis")))

(test-set-fails test-fails2
  (assert false))

(test-set test-cmp
  (test = 1 1)
  (test raises-exc [AssertionError] (test = 1 2))
  (test != 1 2)
  (test raises-exc [AssertionError] (test != 1 1))
  (test < 0 1)
  (test raises-exc [AssertionError] (test < 1 0))
  (test > 1 0)
  (test raises-exc [AssertionError] (test > 0 1)))

(test-set test-is
  (def obj (object))
  (test is obj obj)
  (test is-not obj (object))
  (test raises-exc [AssertionError] (test is obj (object)))
  (test raises-exc [AssertionError] (test is-not obj obj)))

(test-set test-nil
  (test is-nil nil)
  (test is-not-nil 0)
  (test raises-exc [AssertionError] (test is-nil 0))
  (test raises-exc [AssertionError] (test is-not-nil nil)))

(test-set test-almost
  (test aeq 1.00000001 1)
  (test ane 1 2)
  (test raises-exc [AssertionError] (test aeq 1 2))
  (test raises-exc [AssertionError] (test ane 1.00000001 1)))

(test-set test-regex
  (test =~ "abc" "c")
  (test !=~ "abc" "d")
  (test raises-exc [AssertionError] (test =~ "abc" "d"))
  (test raises-exc [AssertionError] (test !=~ "abc" "c")))

(test-set test-items
  (test =: [1 2 3] [3 2 1])
  (test !=: [1 2 3] [3 2])
  (test raises-exc [AssertionError] (test =: [1 2 3] [3 2]))
  (test raises-exc [AssertionError] (test !=: [1 2 3] [3 2 1])))

(test-set test-membership
  (test in 1 [1 2 3])
  (test not-in 0 [1 2 3])
  (test raises-exc [AssertionError] (test in 0 [1 2 3]))
  (test raises-exc [AssertionError] (test not-in 1 [1 2 3])))

(test-set test-raises
  (test raises (assert false))
  (test raises-exc [AssertionError] (assert false))
  (test raises-msg "abc" (raise (ValueError "1abc2")))
  (test not-raises (assert true))
  (test not-raises-exc [AssertionError] (assert true))
  (test not-raises-msg "abc" (raise (ValueError "1ab2c"))))

(test-set test-boolcmp
  (test true 1)
  (test false 0)
  (test not 0)
  (test raises-exc [AssertionError] (test true 0))
  (test raises-exc [AssertionError] (test false 1))
  (test raises-exc [AssertionError] (test not 1)))

(def x 1)

(test-set test-globals
  (test = x 1))
