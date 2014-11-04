(import [hy.importer [import-file-to-module]]
        [hy.models.string [HyString]]
        [hy.models.integer [HyInteger]]
        [hy.models.symbol [HySymbol]]
        [hy.models.expression [HyExpression]]
        [collections [OrderedDict]]
        [os [walk getcwd path]]
        traceback
        warnings
        sys)

(if-python2
  (do
    (try
      (import [cStringIO [StringIO]])
      (catch []
        (import [StringIO [StringIO]])))
    (defmacro --hytest-x [x] `(raise ~x)))
  (do
    (import [io [StringIO]])
    (defmacro --hytest-x [x] `(raise ~x :from nil))))

(def __version__ 0.1)

(try
  (import colorama)
  (catch [])
  (else (colorama.init)))

(defclass SkipException [Exception] [])
(defclass FailException [Exception] [])

(defmacro skip-test [reason]
  `(raise (.SkipException (__import__ "hytest") ~reason)))

(defmacro skip-test-if [cond reason]
  `(if ~cond (raise (.SkipException (__import__ "hytest") ~reason))))

(defmacro skip-test-unless [cond reason]
  `(if-not ~cond (raise (.SkipException (__import__ "hytest") ~reason))))

(defmacro fail-test [&optional [msg ""]]
  `(raise (.FailException (__import__ "hytest") ~msg)))

(defn fm [s &rest args]
  `(% ~(HyString s) (slice (, ~@args) 0 ~(HyInteger (s.count "%")))))

(defmacro --hytest-fm [s &rest args]
  `(% ~s (, ~@args)))

(defn tst [exp msg]
  `(if-not ~exp (raise (AssertionError ~msg))))

(defn cmp-base [op lhs rhs fms]
  (setv [ln rn] [(gensym) (gensym)])
  `(let [[~ln ~lhs] [~rn ~rhs]]
    ~(tst `(~op ~ln ~rn) (fm fms `(repr ~ln) `(repr ~rn)))))

(defn test-eq [lhs rhs] (cmp-base `= lhs rhs "%s != %s"))
(defn test-ne [lhs rhs] (cmp-base `!= lhs rhs "%s == %s"))
(defn test-lt [lhs rhs] (cmp-base `< lhs rhs "%s >= %s"))
(defn test-gt [lhs rhs] (cmp-base `> lhs rhs "%s <= %s"))
(defn test-lte [lhs rhs] (cmp-base `<= lhs rhs "%s > %s"))
(defn test-gte [lhs rhs] (cmp-base `>= lhs rhs "%s < %s"))

(defn test-is [lhs rhs] (cmp-base `is lhs rhs "%s is not %s"))
(defn test-is-not [lhs rhs] (cmp-base `is-not lhs rhs "%s is %s"))

(defn test-is-nil [x] (test-is x `nil))
(defn test-is-not-nil [x] (test-is-not x `nil))

(defn almost-base [op] `(fn [lhs rhs] (~op (round (- lhs rhs) 7) 0)))
(defn test-almost-eq [lhs rhs] (cmp-base (almost-base `=) lhs rhs
                                "%s is not almost equal to %s"))
(defn test-almost-ne [lhs rhs] (cmp-base (almost-base `!=) lhs rhs
                                "%s is almost equal to %s"))

(defn test-regex [s r] (cmp-base `(fn [s r] (.search (__import__ "re") r s)) s r
                        "%s does not match regex %s"))
(defn test-not-regex [s r] (cmp-base `(fn [s r]
                            (not (.search (__import__ "re") r s))) s r
                             "%s matches regex %s"))

(defn items-base [op] `(fn [lhs rhs] (~op (sorted lhs) (sorted rhs))))
(defn test-items-eq [lhs rhs] (cmp-base (items-base `=) lhs rhs
                               "items in %s are not equal to items in %s"))
(defn test-items-ne [lhs rhs] (cmp-base (items-base `!=) lhs rhs
                               "items in %s are equal to items in %s"))

(defn test-true [x] (cmp-base `(fn [x _] x) x `nil "%s is not true"))
(defn test-not [x] (cmp-base `(fn [x _] (not x)) x `nil "%s is not true"))

(defn test-in [x sq] (cmp-base `in x sq "item %s not in sequence %s"))
(defn test-not-in [x sq] (cmp-base `not-in x sq "item %s is in sequence %s"))

(def raise-var (gensym))

(defn test-raises-any [&rest body]
  `(try
    ~@body
    (catch [])
    (else (raise (AssertionError "code did not raise exception")))))

(defn test-raises [exceptions &rest body]
  (setv strexc (HyString (.join ", " (map str exceptions))))
  `(try
    ~@body
    (catch [[~@exceptions]])
    (else (raise (AssertionError (+ "code did not raise one of: " ~strexc))))))

(defn test-raises-msg [m &rest body]
  `(try
    ~@body
    (catch [~raise-var Exception]
      (if-not (.search (__import__ "re") ~m (str ~raise-var))
        (raise (AssertionError
          ~(fm "exception message '%s' did not match " `(str ~raise-var) m)))))
    (else (raise (AssertionError "code did not raise exception")))))

(defn test-not-raises-any [&rest body]
  `(try
    ~@body
    (catch [~raise-var Exception]
      (--hytest-x
        (AssertionError (+ "code raised exception " (repr ~raise-var)))))))

(defn test-not-raises [exceptions &rest body]
  `(try
    ~@body
    (catch [~raise-var [~@exceptions]]
      (--hytest-x
        (AssertionError (+ "code raised exception " (repr ~raise-var)))))))

(defn test-not-raises-msg [m &rest body]
  `(try
    ~@body
    (catch [~raise-var Exception]
      (if (.search (__import__ "re") ~m (str ~raise-var))
        (--hytest-x
          (AssertionError ~(fm "raised exception message '%s' matched %s"
            `(str ~raise-var) m)))))))

(def opmap {"=" test-eq
            "==" test-eq
            "!=" test-ne
            "<" test-lt
            ">" test-gt
            "<=" test-lte
            ">=" test-gte
            "eq" test-eq
            "ne" test-ne
            "lt" test-lt
            "gt" test-gt
            "lte" test-lte
            "gte" test-gte
            "is" test-is
            "is-not" test-is-not
            "is-nil" test-is-nil
            "is-not-nil" test-is-not-nil
            "is-none" test-is-nil
            "is-not-none" test-is-not-nil
            "~" test-almost-eq
            "!~" test-almost-ne
            "aeq" test-almost-eq
            "ane" test-almost-ne
            "=~" test-regex
            "!=~" test-not-regex
            "re" test-regex
            "not-re" test-not-regex
            "=:" test-items-eq
            "!=:" test-items-ne
            "ieq" test-items-eq
            "ine" test-items-ne
            "True" test-true
            "False" test-not
            "not" test-not
            "in" test-in
            "not-in" test-not-in
            "raises" test-raises-any
            "raises-exc" test-raises
            "raises-msg" test-raises-msg
            "not-raises" test-not-raises-any
            "not-raises-exc" test-not-raises
            "not-raises-msg" test-not-raises-msg})

(defmacro test [name &rest args]
  (setv sname (.replace (str name) "_" "-"))
  (if-not (in sname opmap)
    (macro-error name (% "unknown comparator: %s" sname)))
  (apply (get opmap sname) args))

(def mods [])
(def tests (OrderedDict))

(defn add-test [func file]
  (if-not (in file tests)
    (assoc tests file (.OrderedDict (__import__ "collections"))))
  (setv mytests (get tests file))
  (if (in func.__name__ mytests)
    (warnings.warn (+ "duplicate test: " file ":" func.__name__)))
  (assoc mytests func.__name__ func))

(defn get-setup-and-teardown [body]
  (setv body (list body))
  (defmacro get-f2 [x] `(if (and body (get body 0)) (get (get body 0) 0) nil))
  (if (= (get-f2 body) (HySymbol "test_setup"))
    (setv setup (slice (.pop body 0) 1))
    (setv setup (HyExpression [])))
  (if (= (get-f2 body) (HySymbol "test_teardown"))
    (setv teardown (slice (.pop body 0) 1))
    (setv teardown (HyExpression [])))
  (, (tuple body) setup teardown))

(defmacro test-set [name &rest body]
  (setv [body setup teardown] (get-setup-and-teardown body))
  `(do
    (defn ~name [] ~@setup (try (do ~@body) (finally ~@teardown)))
    (.add-test (__import__ "hytest") ~name __file__)))

(defmacro test-set-fails [name &rest body]
  (setv [body setup teardown] (get-setup-and-teardown body))
  (setv skipexc (gensym))
  `(do
    (defn ~name []
      ~@setup
      (setv ~skipexc (getattr (__import__ "hytest") "SkipException"))
      (try
        (do ~@body)
        (catch [~skipexc] (raise))
        (catch [])
        (finally ~@teardown)))
    (.add-test (__import__ "hytest") ~name __file__)))

(defn main [this &rest args]
  (if (or (in "-h" args) (in "--help" args))
    (sys.exit (% "usage: %s <tests-to-run>" this)))
  (setv wanted-names args)
  (defn starstr [s]
    (setv stars (* "*" (len s)))
    (print stars)
    (print s)
    (print stars))
  (load-tests)
  (setv wanted (OrderedDict))
  (when wanted-names
    (for [n wanted-names]
      (if-not (in ":" n)
        (sys.exit (% "test name %s must have module specifier" n))
        (setv [mod test] (n.split ":")))
      (if-not (in mod tests)
        (sys.exit (+ "unknown module: " mod)))
      (if-not (in test (get tests mod))
        (sys.exit (+ "unknown test: " n)))
      (if-not (in mod wanted)
        (assoc wanted mod (OrderedDict)))
      (assoc (get wanted mod) test (get (get tests mod) test))))
  (unless wanted
    (setv wanted tests))
  (setv run 0)
  (setv skipped [])
  (setv traces [])
  (setv outputs (, [] [] []))
  (setv stdout sys.stdout)
  (setv stderr sys.stderr)
  (for [[mod mtests] (wanted.items)]
    (sys.stdout.write (% "\033[34m%s\033[0m " mod))
    (for [[name tst] (mtests.items)]
      (setv fullname (--hytest-fm "%s:%s" mod name))
      (setv out (StringIO))
      (setv err (StringIO))
      (setv sys.stdout out)
      (setv sys.stderr err)
      (try
        (try
          (tst)
          (catch [] (raise))
          (finally
            (setv sys.stdout stdout)
            (setv sys.stderr stderr)))
        (catch [e SkipException]
          (skipped.append (, fullname (str e)))
          (.append (get outputs 1) (, fullname (out.getvalue) (err.getvalue)))
          (sys.stdout.write "\033[35mS\033[0m"))
        (catch [e Exception]
          (sys.stdout.write "\033[31mF\033[0m")
          (traces.append (, fullname (traceback.format-exc)))
          (.append (get outputs 0) (, fullname (out.getvalue) (err.getvalue))))
        (else
          (sys.stdout.write "\033[32m.\033[0m")
          (.append (get outputs 2) (, fullname (out.getvalue) (err.getvalue))))
        (finally
          (+= run 1))))
    (print))
  (defn print-bufs [n]
    (setv st (get outputs n))
    (if-not st
      (raise (ValueError "")))
    (setv (, tst out err) (get st 0))
    (when out
      (starstr (% "CAPTURED STDOUT: %s: " tst))
      (print out))
    (when err
      (starstr (% "CAPTURED STDERR: %s: " tst))
      (print err))
    (st.pop 0))
  (while true
    (try
      (print-bufs 2)
      (catch [ValueError] (break))))
  (for [[tst trace] traces]
    (print_bufs 0)
    (print "\033[31m")
    (starstr (% "ERROR: %s:" tst))
    (print trace)
    (print "\033[0m"))
  (for [[tst reason] skipped]
    (print_bufs 1)
    (print "\033[35m")
    (starstr (--hytest-fm "SKIPPED %s: %s" tst reason))
    (print "\033[0m"))
  (print (% "\033[34mTests run: %d" run))
  (print (% "\033[32mTests succeeded: %d" (- run (len traces) (len skipped))))
  (print (% "\033[31mTests failed: %d\033[0m" (len traces)))
  (print (% "\033[35mTests skipped: %d\033[0m" (len skipped))))

(defn find-tests []
  (setv test-paths [])
  (for [[root dirs files] (walk (getcwd))]
    (if (= root (getcwd)) (setv root ""))
    (let [[repl-dirs []]]
      (for [d dirs]
        (if (d.startswith "test")
          (repl-dirs.append (path.join root d))))
      (setv (slice dirs) repl-dirs))
    (for [f files]
      (if (and (f.startswith "test") (= (get (path.splitext f) 1) ".hy"))
        (test-paths.append (path.join root f)))))
  test-paths)

(defn load-tests []
  (for [p (find-tests)]
    (mods.append
      (import-file-to-module (get (path.splitext (path.basename p)) 0) p))))
