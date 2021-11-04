chapter\<open>Evaluation\<close>

text\<open>Term Annotation Antiquotations (TA) can be evaluated with the help of the value* command.\<close>

theory 
  Evaluation
imports 
  "Isabelle_DOF-tests.TermAntiquotations"
begin

text\<open>The value* command uses the same code as the value command
and adds the possibility to evaluate Term Annotation Antiquotations (TA).
For that an elaboration of the term referenced by a TA must be done before
passing it to the evaluator.
The current implementation is based on referential equality, syntactically, and
with the help of HOL, on referential equivalence, semantically:
Some built-ins remain as unspecified constants:
\<^item> the docitem TA offers a way to check the reference of class instances
  without checking the instances type.
  It must be avoided for certification
\<^item> the termrepr TA is left as unspecified constant for now.
   A major refactoring of code should be done to enable
  referential equivalence for termrepr, by changing the dependency
  between the Isa_DOF theory and the Assert theory.
  The assert_cmd function in Assert should use the value* command
  functions, which make the elaboration of the term
  referenced by the TA before passing it to the evaluator
The emphasis of this presentation is to present the evaluation possibilities and limitations
of the current implementation.
\<close>

text\<open>

case : attribute not initialized

\<close>

text\<open>We can validate a term with TA:\<close>
term*\<open>@{thm \<open>HOL.refl\<close>}\<close>

text\<open>Now we can evaluate a term with TA:
the current implementation return the term which references the object referenced by the TA.
Here the evualuation of the TA will return the HOL.String which references the theorem:
\<close>
value*\<open>@{thm \<open>HOL.refl\<close>}\<close>

text\<open>An instance class is an object which allows us to define the concepts we want in an ontology.
It is a concept which will be used to implement an ontology. It has roughly the same meaning as
an individual in an OWL ontology.
The validation process will check that the instance class @{docitem \<open>xcv1\<close>} is indeed
an instance of the class @{doc_class A}:
\<close>
term*\<open>@{A \<open>xcv1\<close>}\<close>

text\<open>The instance class @{docitem \<open>xcv1\<close>} is not an instance of the class B:
\<close>
(* Error:
term*\<open>@{B \<open>xcv1\<close>}\<close>*)

text\<open>We can evaluate the instance class. The current implementation returns
the value of the instance, i.e. a collection of every attribute of the instance: 
\<close>
value*\<open>@{A \<open>xcv1\<close>}\<close>

text\<open>We can also get the value of an attribute of the instance:\<close>
value*\<open>A.x @{A \<open>xcv1\<close>}\<close>

text\<open>If the attribute of the instance is not initialized, we get an undefined value,
whose type is the type of the attribute:\<close>
term*\<open>level @{C \<open>xcv2\<close>}\<close>
value*\<open>level @{C \<open>xcv2\<close>}\<close>

text\<open>The value of a TA is the term itself:\<close>
term*\<open>C.g @{C \<open>xcv2\<close>}\<close>
value*\<open>C.g @{C \<open>xcv2\<close>}\<close>

text\<open>Some terms can be validated, i.e. the term will be checked,
and the existence of every object referenced by a TA will be checked,
and can be evaluated by using referential equivalence.
The existence of the instance @{docitem \<open>xcv4\<close>} can be validated,
and the fact that it is an instance of the class @{doc_class F} } will be checked:\<close>
term*\<open>@{F \<open>xcv4\<close>}\<close>

text\<open>We can also evaluate the instance @{docitem \<open>xcv4\<close>}.
The attribute \<open>b\<close> of the instance @{docitem \<open>xcv4\<close>} is of type @{typ "(A \<times> C) set"}
but the instance @{docitem \<open>xcv4\<close>} initializes the attribute by using the \<open>docitem\<close> TA.
Then the instance can be evaluate but only the references of the classes of the set
used in the \<open>b\<close> attribute will be checked, and the type of these classes will not:
\<close>
value* \<open>@{F \<open>xcv4\<close>}\<close>

text\<open>If we want the classes to be checked,
we can use the TA which will also check the type of the instances.
The instance @{A \<open>xcv3\<close>} is of type @{typ "A"} and the instance @{C \<open>xcv2\<close>} is of type @{typ "C"}:
\<close>
update_instance*[xcv4::F, b+="{(@{A ''xcv3''},@{C ''xcv2''})}"]

text\<open>Using a TA in terms is possible, and the term is evaluated:\<close>
value*\<open>[@{thm \<open>HOL.refl\<close>}, @{thm \<open>HOL.refl\<close>}]\<close>
value*\<open>@{thm ''HOL.refl''} = @{thm (''HOL.refl'')}\<close>

ML\<open>
@{thm "refl"}
\<close>

text\<open>There are still some limitations.
The terms passed as arguments to the TA are not simplified and their evaluation fails:
\<close>
(* Error:
value*\<open>@{thm (''HOL.re'' @ ''fl'')}\<close>
value*\<open>@{thm ''HOL.refl''} = @{thm (''HOL.re'' @ ''fl'')}\<close>*)

text\<open>The type checking is unaware that a class is subclass of another one.
The @{doc_class "G"} is a subclass of the class @{doc_class "C"}, but one can not use it
to update the instance @{docitem \<open>xcv4\<close>}:
\<close>
(* Error:
update_instance*[xcv4::F, b+="{(@{A ''xcv3''},@{G ''xcv5''})}"]*)

end
