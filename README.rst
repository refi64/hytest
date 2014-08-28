HyTest
======

HyTest is a really cool unit testing framework for `Hy <http://docs.hylang.org/>`_ (think Python+Lisp). Actually, as far as I know, it's the *only* unit testing framework for Hy. Here's an example:

.. code:: clojure
   
   (require hytest) ; load HyTest
   
   (test-set abc ; define a test set, similar to a unittest test case
     (test-setup ; test setup
       (def x 0)
       (def y 1)
       (def z nil)
     )
     (test-teardown ; test teardown; executed regardless of whether or not test failed
       ; nothing to see here!
     )
     (test = 1 1) ; test for equality
     (test == 1 1) ; same as =
     (test eq 1 1) ; again, same as =
     (test != 1 0) ; test for inequality
     (test ne 1 0) ; same as !=
     (test < 0 1) ; test for less-than
     (test lt 0 1) ; same as <
     (test > 1 0) ; test for greater-than
     (test gt 1 0) ; same as >
     (test >= 1 1) ; greater-than-or-equal-to
     (test gte 1 1) ; same as >=
     (test <= 1 1) ; less-than-or-equal-to
     (test lte 1 1) ; same as <=
     (test is x x) ; test for identity; sort of like assert x is x
     (test is-not x y) ; test for identity inequality; sort of like assert x is not y
     (test is-nil z) ; test to see if equal-to None/nil
     (test is-not-nil x) ; opposite of is-nil
     (test is-none z) ; same as is-nil
     (test is-not-none z) ; same as is-not-nil
     (test ~ 0 0.00000001) ; test for almost equal(like unittest's assertAlmostEqual)
     (test aeq 0 0.00000001) ; same as ~
     (test !~ 0 1) ; test for not almost equal(like unittest's assertNotAlmostEqual)
     (test ane 0 1); same as !~
     (test =~ "abc" "b") ; test to see if "abc" matches regex "a"
     (test re "abc" "b") ; same as =~
     (test !=~ "abc" "d") ; opposite of =~
     (test not-re "abc" "d") ; same as !=~
     (test =: [1 2 3] [3 1 2]) ; test to see if both items are equal when sorted
     (test ieq [1 2 3] [3 1 2]) ; same as =:
     (test !=: [1 2 3] [3 1]) ; opposite of =:
     (test ine [1 2 3] [3 1]) ; same as !=:
     (test true 1) ; test to see if 1 is truthy(so that (bool 1) is true)
     (test True 1) ; same as true
     (test false 0) ; test to see if 0 is falsy(so that (bool 0) is false)
     (test False 0) ; same as false
     (test not 0) ; same as false
     (test in 1 [1 2 3]) ; test for membership
     (test not-in 1 [2 3]) ; opposite of in
     (test raises (assert false)) ; test that the code that follows raises an exception
     (test not-raises (assert true)) ; opposite of raises
     (test raises-exc [AssertionError] (assert false)) ; test that the code that follows raises one of the exceptions in the list
     (test not-raises-exc [AssertionError] (assert false)) ; test that one of the given exceptions is NOT raised by the code that follows
     (test raises-msg "abc" (raise (ValueError "abc"))) ; test that the code that follows raises an exception whose message matches the regex "abc"
     (test not-raises-msg "abc" (raise (ValueError "ab"))) ; opposite of raises-msg
   )
   
   (test-set xyz
     (if true
       (skip-test "Reason for skipping here") ; skip-test skips the current test
     )
   )
   
   (test-set-fails fls ; test-set-fails defines a test set that *should* fail
     (test not 1)
   )

To run the tests, just run::
   
   $ hytest
