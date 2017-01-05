(require [hytest [*]])
(import [hytest [find-tests FailException]]
        [os [getcwd makedirs path]]
        [shutil [rmtree]]
        [tempfile [mkdtemp]])

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
  (assert False))

(test-set test-cmp
  (test = 1 1)
  (test raises-exc [FailException] (test = 1 2))
  (test != 1 2)
  (test raises-exc [FailException] (test != 1 1))
  (test < 0 1)
  (test raises-exc [FailException] (test < 1 0))
  (test > 1 0)
  (test raises-exc [FailException] (test > 0 1)))

(test-set test-is
  (def obj (object))
  (test is obj obj)
  (test is-not obj (object))
  (test raises-exc [FailException] (test is obj (object)))
  (test raises-exc [FailException] (test is-not obj obj)))

(test-set test-nil
  (test is-nil None)
  (test is-not-nil 0)
  (test raises-exc [FailException] (test is-nil 0))
  (test raises-exc [FailException] (test is-not-nil None)))

(test-set test-almost
  (test aeq 1.00000001 1)
  (test ane 1 2)
  (test raises-exc [FailException] (test aeq 1 2))
  (test raises-exc [FailException] (test ane 1.00000001 1)))

(test-set test-regex
  (test =~ "abc" "c")
  (test !=~ "abc" "d")
  (test raises-exc [FailException] (test =~ "abc" "d"))
  (test raises-exc [FailException] (test !=~ "abc" "c")))

(test-set test-items
  (test =: [1 2 3] [3 2 1])
  (test !=: [1 2 3] [3 2])
  (test raises-exc [FailException] (test =: [1 2 3] [3 2]))
  (test raises-exc [FailException] (test !=: [1 2 3] [3 2 1])))

(test-set test-membership
  (test in 1 [1 2 3])
  (test not-in 0 [1 2 3])
  (test raises-exc [FailException] (test in 0 [1 2 3]))
  (test raises-exc [FailException] (test not-in 1 [1 2 3])))

(test-set test-raises
  (test raises (assert False))
  (test raises-exc [AssertionError] (assert False))
  (test raises-msg "abc" (raise (ValueError "1abc2")))
  (test not-raises (assert True))
  (test not-raises-exc [AssertionError] (assert True))
  (test not-raises-msg "abc" (raise (ValueError "1ab2c"))))

(test-set test-boolcmp
  (test True 1)
  (test False 0)
  (test not 0)
  (test raises-exc [FailException] (test True 0))
  (test raises-exc [FailException] (test False 1))
  (test raises-exc [FailException] (test not 1)))

(def x 1)

(test-set test-globals
  (test = x 1))

(defn touch [&rest parts]
  "Join the path `parts` and touch the resulting filename."
  (.close (open (apply path.join parts) "a")))

(test-set test-find-tests
  (let [root (mkdtemp)]
    (try
     (do (makedirs (path.join root "a" "b" "c"))
         (touch root "test_root.hy")
         (touch root "a" "test_a.hy")
         (touch root "a" "b" "test_b.hy")
         (touch root "a" "b" "c" "test_c.hy")
         (test = (find-tests root)
               [(path.join root "test_root.hy")
                (path.join root "a" "test_a.hy")
                (path.join root "a" "b" "test_b.hy")
                (path.join root "a" "b" "c" "test_c.hy")]))
     (finally (rmtree root)))))
