(*************************************************************************
 * Copyright (C) 
 *               2019      The University of Exeter 
 *               2018-2019 The University of Paris-Saclay
 *               2018      The University of Sheffield
 *
 * License:
 *   This program can be redistributed and/or modified under the terms
 *   of the 2-clause BSD-style license.
 *
 *   SPDX-License-Identifier: BSD-2-Clause
 *************************************************************************)

section\<open>An example ontology for scientific, MINT-oriented papers.\<close>

theory scholarly_paper
  imports "../../DOF/Isa_COL"
  keywords "author*" "abstract*"
           "Definition*" "Lemma*" "Theorem*"  :: document_body
  and      "assert*"                          :: thy_decl


begin

text\<open>Scholarly Paper provides a number of standard text - elements for scientific papers.
They were introduced in the following.\<close>

subsection\<open>General Paper Structuring Elements\<close>
doc_class title =
   short_title :: "string option"  <=  "None"
    
doc_class subtitle =
   abbrev ::      "string option"  <=  "None"
   
(* adding a contribution list and checking that it is cited as well in tech as in conclusion. ? *)

doc_class author =
   email       :: "string" <= "''''"
   http_site   :: "string" <= "''''"
   orcid       :: "string" <= "''''"
   affiliation :: "string"


doc_class abstract =
   keywordlist        :: "string list"   <= "[]" 
   principal_theorems :: "thm list"


ML\<open>
val _ =
  ODL_Command_Parser.document_command ("abstract*", @{here}) "Textual Definition"
    {markdown = true, body = true}
    (Onto_Macros.enriched_document_cmd_exp (SOME "abstract") []);

val _ =
  ODL_Command_Parser.document_command ("author*", @{here}) "Textual Definition"
    {markdown = true, body = true}
    (Onto_Macros.enriched_document_cmd_exp (SOME "author") []);
\<close>

text\<open>Scholarly Paper is oriented towards the classical domains in science:
\<^enum> mathematics
\<^enum> informatics
\<^enum> natural sciences
\<^enum> technology (= engineering)

which we formalize into:\<close>

doc_class text_section = text_element +
   main_author :: "author option"  <=  None
   fixme_list  :: "string list"    <=  "[]" 
   level       :: "int  option"    <=  "None"   
   (* this attribute enables doc-notation support section* etc.
      we follow LaTeX terminology on levels 
                part          = Some -1
                chapter       = Some 0
                section       = Some 1
                subsection    = Some 2
                subsubsection = Some 3
       ... *)
   (* for scholarly paper: invariant level > 0 *)


doc_class "conclusion" = text_section +
   main_author :: "author option"  <=  None
   
doc_class related_work = "conclusion" +
   main_author :: "author option"  <=  None

doc_class bibliography = text_section +
   style       :: "string option"  <=  "Some ''LNCS''"

doc_class annex = "text_section" +
   main_author :: "author option"  <=  None

(*
datatype sc_dom = math | info | natsc | eng 
*)


subsection\<open>Introductions\<close>

doc_class introduction = text_section +
   comment :: string
   claims  :: "thm list"

text\<open>Technical text-elements posses a status: they can be either an \<^emph>\<open>informal explanation\<close> /
description or a kind of introductory text to definition etc. or a \<^emph>\<open>formal statement\<close> similar
to :

\<^bold>\<open>Definition\<close> 3.1: Security. 
As Security of the system we define etc...

A formal statement can, but must not have a reference to true formal Isabelle/Isar definition. 
\<close>

subsection\<open>Technical Content and its Formats\<close>

datatype status = formal | semiformal | description

text\<open>The class \<^verbatim>\<open>technical\<close> regroups a number of text-elements that contain typical 
"technical content" in mathematical or engineering papers: definitions, theorems, lemmas, examples.  \<close>

(* OPEN PROBLEM: connection between referentiable and status. This should be explicit 
   and computable. *)


doc_class technical = text_section +
   definition_list :: "string list" <=  "[]"
   status          :: status <= "description"
   formal_results  :: "thm list"
   invariant L1    :: "\<lambda>\<sigma>::technical. the (level \<sigma>) > 0"

type_synonym tc = technical (* technical content *)


text \<open>This a \<open>doc_class\<close> of \<^verbatim>\<open>examples\<close> in the broadest possible sense : they are \emph{not}
necessarily considered as technical content, but may occur in an article. 
Note that there are \<open>doc_class\<close>es of \<^verbatim>\<open>math_example\<close>s and \<^verbatim>\<open>tech_example\<close>s which 
follow a more specific regime of mathematical or engineering content.
\<close>
(* An example for the need of multiple inheritance on classes ? *)

doc_class example  = text_section + 
   referentiable   :: bool <= True
   status          :: status <= "description"
   short_name      :: string <= "''''"


subsection\<open>Freeform Mathematical Content\<close>

text\<open>We follow in our enumeration referentiable mathematical content class the AMS style and its
provided \<^emph>\<open>theorem environments\<close> (see \<^verbatim>\<open>texdoc amslatex\<close>). We add, however, the concepts 
\<^verbatim>\<open>axiom\<close>, \<^verbatim>\<open>rule\<close> and \<^verbatim>\<open>assertion\<close> to the list. A particular advantage of \<^verbatim>\<open>texdoc amslatex\<close> is 
that it is well-established and compatible with many LaTeX - styles.\<close>

datatype math_content_class = "defn"   | "axm"  | "thm"  | "lem" | "cor" | "prop" 
                            | "expl"   | "rule" | "assn" 
                            | rem      | "notation" | "terminology"

(*
thm Theorem Italic 
cor Corollary Italic 
lem Lemma Italic
prop Proposition 
defn Definition
expl Example 

rem Remark
notation
terminology
*)
text\<open>Instances of the \<open>doc_class\<close> \<^verbatim>\<open>math_content\<close> are by definition @{term "semiformal"}; they may
be non-referential, but in this case they will not have a @{term "short_name"}.\<close>

doc_class math_content = tc +
   referentiable :: bool <= True
   short_name    :: string <= "''''"
   status        :: status <= "semiformal"
   mcc           :: "math_content_class" <= "thm" 
   invariant s1  :: "\<lambda> \<sigma>::math_content. \<not>referentiable \<sigma> \<longrightarrow> short_name \<sigma> = ''''"
   invariant s2  :: "\<lambda> \<sigma>::math_content. technical.status \<sigma> = semiformal"
type_synonym math_tc = math_content

text\<open>The class \<^typ>\<open>math_content\<close> is perhaps more adequaltely described as "math-alike content".
Sub-classes can englobe instances such as:
\<^item> terminological definitions such as:
  \<open>Definition*[assessor::sfc, short_name="''assessor''"]\<open>entity that carries out an assessment\<close>\<close>
\<^item> free-form mathematical definitions such as:
  \<open>Definition*[process_ordering, short_name="''process ordering''"]\<open>
   We define \<open>P \<sqsubseteq> Q \<equiv> \<psi>\<^sub>\<D> \<and> \<psi>\<^sub>\<R> \<and> \<psi>\<^sub>\<M> \<close>,  where \<^vs>\<open>-0.2cm\<close>
   1) \<^vs>\<open>-0.2cm\<close> \<open>\<psi>\<^sub>\<D> = \<D> P \<supseteq> \<D> Q \<close>
   2) ...
   \<close>\<close>
\<^item> semi-formal descriptions, which are free-form mathematical definitions on which finally
  an attribute with a formal Isabelle definition is attached. 

\<close>


(* type qualification is a work around *)

text\<open>The intended use for the \<open>doc_class\<close>es \<^verbatim>\<open>math_motivation\<close> (or \<^verbatim>\<open>math_mtv\<close> for short),
     \<^verbatim>\<open>math_explanation\<close> (or \<^verbatim>\<open>math_exp\<close> for short) and 
     \<^verbatim>\<open>math_example\<close> (or \<^verbatim>\<open>math_ex\<close> for short)
     are \<^emph>\<open>informal\<close> descriptions of semi-formal definitions (by inheritance).
     Math-Examples can be made referentiable triggering explicit, numbered presentations.\<close>
doc_class math_motivation  = tc +  
   referentiable :: bool <= False
type_synonym math_mtv = math_motivation

doc_class math_explanation  = tc +
   referentiable :: bool <= False
type_synonym math_exp = math_explanation


text\<open>The intended use for the \<open>doc_class\<close> \<^verbatim>\<open>math_semiformal_statement\<close> (or \<^verbatim>\<open>math_sfs\<close> for short) 
     are semi-formal mathematical content (definition, lemma, etc.). They are referentiable entities.
     They are NOT formal, i.e. Isabelle-checked formal content, but can be in close link to these.\<close>
doc_class math_semiformal  = math_content +
   referentiable :: bool <= True
type_synonym math_sfc = math_semiformal

subsection\<open>Instances of the abstract classes Definition / Class / Lemma etc.\<close>

text\<open>The key class definitions are motivated by the AMS style.\<close>   

doc_class "definition"  = math_content +
   referentiable :: bool <= True
   mcc           :: "math_content_class" <= "defn" 
   invariant d1  :: "\<lambda> \<sigma>::definition. mcc \<sigma> = defn" (* can not be changed anymore. *)

doc_class "theorem"     = math_content +
   referentiable :: bool <= True
   mcc           :: "math_content_class" <= "thm" 
   invariant d2  :: "\<lambda> \<sigma>::theorem. mcc \<sigma> = thm"

doc_class "lemma"     = math_content +
   referentiable :: bool <= "True"
   mcc           :: "math_content_class" <= "lem" 
   invariant d3  :: "\<lambda> \<sigma>::lemma. mcc \<sigma> = lem"

doc_class "corollary"     = math_content +
   referentiable :: bool <= "True"
   mcc           :: "math_content_class" <= "cor" 
   invariant d4  :: "\<lambda> \<sigma>::corollary. mcc \<sigma> = thm"

doc_class "math_example"     = math_content +
   referentiable :: bool <= "True"
   mcc           :: "math_content_class" <= "expl" 
   invariant d5  :: "\<lambda> \<sigma>::math_example. mcc \<sigma> = expl"


subsubsection\<open>Ontological Macros \<^verbatim>\<open>Definition*\<close> , \<^verbatim>\<open>Lemma**\<close>, \<^verbatim>\<open>Theorem*\<close> ... \<close>

text\<open>These ontological macros allow notations are defined for the class 
  \<^typ>\<open>math_content\<close> in order to allow for a variety of free-form formats;
  in order to provide specific sub-classes, default options can be set
  in order to support more succinct notations and avoid constructs
  such as :

  \<^theory_text>\<open>Definition*[l::"definition"]\<open>...\<close>\<close>.

  Instead, the more convenient global declaration 
  \<^theory_text>\<open>declare[[Definition_default_class="definition"]]\<close>
  supports subsequent abbreviations:

    \<^theory_text>\<open>Definition*[l]\<open>...\<close>\<close>.
\<close>

ML\<open>
val (Definition_default_class, Definition_default_class_setup) 
     = Attrib.config_string \<^binding>\<open>Definition_default_class\<close> (K "");
val (Lemma_default_class, Lemma_default_class_setup) 
     = Attrib.config_string \<^binding>\<open>Lemma_default_class\<close> (K "");
val (Theorem_default_class, Theorem_default_class_setup) 
     = Attrib.config_string \<^binding>\<open>Theorem_default_class\<close> (K "");


\<close>
setup\<open>Definition_default_class_setup\<close>
setup\<open>Lemma_default_class_setup\<close>
setup\<open>Theorem_default_class_setup\<close>

ML\<open> local open ODL_Command_Parser in

val _ = 
  ODL_Command_Parser.document_command ("Definition*", @{here}) "Textual Definition"
    {markdown = true, body = true}
    (fn meta_args => fn thy =>
      let
        val ddc = Config.get_global thy Definition_default_class
        val use_Definition_default = SOME(((ddc = "") ? (K "math_content")) ddc)
      in
        Onto_Macros.enriched_formal_statement_command 
         use_Definition_default [("mcc","defn")] meta_args thy
      end);

val _ =
  ODL_Command_Parser.document_command ("Lemma*", @{here}) "Textual Lemma Outline"
    {markdown = true, body = true}
    (fn meta_args => fn thy =>
      let
        val ddc = Config.get_global thy Definition_default_class
        val use_Lemma_default = SOME(((ddc = "") ? (K "math_content")) ddc)
      in
        Onto_Macros.enriched_formal_statement_command
          use_Lemma_default [("mcc","lem")] meta_args thy
      end);

val _ =
  ODL_Command_Parser.document_command ("Theorem*", @{here}) "Textual Theorem Outline"
    {markdown = true, body = true}
    (fn meta_args => fn thy =>
      let
        val ddc = Config.get_global thy Definition_default_class
        val use_Theorem_default = SOME(((ddc = "") ? (K "math_content")) ddc)
      in
        Onto_Macros.enriched_formal_statement_command 
          use_Theorem_default [("mcc","thm")] meta_args thy
      end);

end 
\<close>


subsection\<open>Formal Mathematical Content\<close>
text\<open>While this library is intended to give a lot of space to freeform text elements in
order to counterbalance Isabelle's standard view, it should not be forgot that the real strength
of Isabelle is its ability to handle both - and to establish links between both worlds. Therefore:\<close>

doc_class math_formal  = math_content +
   referentiable :: bool <= False
   status        :: status <= "formal"
   properties    :: "term list"
type_synonym math_fc = math_formal

doc_class  assertion = math_formal +
   referentiable :: bool <= True (* No support in Backend yet. *)
   status        :: status <= "formal"
   properties    :: "term list"


ML\<open>
(* TODO : Rework this code and make it closer to Definition*. There is still 
   a rest of "abstract classes in it: any class possessing a properties attribute
   is admissible to this command, not just  ... *)
local open ODL_Command_Parser in

fun assertion_cmd'((((((oid,pos),cid_pos),doc_attrs),name_opt:string option),modes : string list),
                prop) =
    let fun conv_2_holstring thy =  (bstring_to_holstring (Proof_Context.init_global thy))
        fun conv_attrs thy = (("properties",pos),"[@{termrepr ''"^conv_2_holstring thy prop ^" ''}]")
                             ::doc_attrs  
        fun conv_attrs' thy = map (fn ((lhs,pos),rhs) => (((lhs,pos),"+="),rhs)) (conv_attrs thy)
        fun mks thy = case DOF_core.get_object_global_opt oid thy of
                   SOME NONE => (error("update of declared but not created doc_item:" ^ oid))
                 | SOME _ => (update_instance_command (((oid,pos),cid_pos),conv_attrs' thy) thy)
                 | NONE   => (create_and_check_docitem 
                                 {is_monitor = false} {is_inline = false} 
                                 oid pos cid_pos (conv_attrs thy) thy)
        val check = (assert_cmd name_opt modes prop) o Proof_Context.init_global
    in 
        (* Toplevel.keep (check o Toplevel.context_of) *)
        Toplevel.theory (fn thy => (check thy; mks thy))
    end

val attributes = attributes (* re-export *)

end
val _ =
  Outer_Syntax.command @{command_keyword "assert*"} 
                       "evaluate and print term"
                       (attributes -- opt_evaluator -- opt_modes  -- Parse.term  >> assertion_cmd'); 

\<close>

subsubsection*[ex_ass::example]\<open>Example\<close>
text\<open>Assertions allow for logical statements to be checked in the global context). \<close>
assert*[ass1::assertion, short_name = "\<open>This is an assertion\<close>"] \<open>(3::int) < 4\<close>

subsection\<open>Example Statements\<close>

text\<open> \<^verbatim>\<open>examples\<close> are currently considered \<^verbatim>\<open>technical\<close>. Is a main category to be refined
      via inheritance. \<close> 

doc_class tech_example       = technical +
   referentiable :: bool <= True
   tag :: "string" <=  "''''"




subsection\<open>Content in Engineering/Tech Papers \<close>
text\<open>This section is currently experimental and not supported by the documentation 
     generation backend.\<close>

doc_class engineering_content = tc +
   short_name :: string <= "''''"
   status     :: status
type_synonym eng_c = engineering_content

doc_class "experiment"  = eng_c +
   tag :: "string" <=  "''''"

doc_class "evaluation"  = eng_c +
   tag :: "string" <=  "''''"

doc_class "data"  = eng_c +
   tag :: "string" <=  "''''"

subsection\<open>Some Summary\<close>

print_doc_classes

print_doc_class_template "definition" (* just a sample *)


subsection\<open>Structuring Enforcement in Engineering/Math Papers \<close>
(* todo : could be finer *)

text\<open> Besides subtyping, there is another relation between
doc\_classes: a class can be a \<^emph>\<open>monitor\<close> to other ones,
which is expressed by occurrence in the where clause.
While sub-classing refers to data-inheritance of attributes,
a monitor captures structural constraints -- the order --
in which instances of monitored classes may occur.

The control of monitors is done by the commands:
\<^item> \<^verbatim>\<open> monitor <oid::class_type, <attributes-defs> > \<close>
\<^item> \<^verbatim>\<open> close_monitor <oid[::class_type],<attributes-updates>> \<close>

where the automaton of the monitor class is expected
to be in a final state.

Monitors can be nested.

Classes neither directly or  indirectly (via inheritance)
mentioned in the monitor clause are \<^emph>\<open>independent\<close> from
the monitor and may occur freely, \ie{} in arbitrary order.n \<close>


text \<open>underlying idea: a monitor class automatically receives a  
    \<^verbatim>\<open>trace\<close> attribute in which a list of observed class-ids is maintained.
    The \<^verbatim>\<open>trace\<close> is a \<^emph>\<open>`predefined id`\<close> like \<^verbatim>\<open>main\<close> in C. It can be accessed
    like any other attribute of a class instance, \ie{} a document item.\<close>

doc_class article = 
   style_id :: string                <= "''LNCS''"
   version  :: "(int \<times> int \<times> int)"  <= "(0,0,0)"
   accepts "(title           ~~ 
            \<lbrakk>subtitle\<rbrakk>        ~~
            \<lbrace>author\<rbrace>\<^sup>+         ~~ 
            abstract          ~~
            \<lbrace>introduction\<rbrace>\<^sup>+   ~~ 
            \<lbrace>technical || example \<rbrace>\<^sup>+      ~~
            \<lbrace>conclusion\<rbrace>\<^sup>+     ~~  
            bibliography      ~~
            \<lbrace>annex\<rbrace>\<^sup>* )"


ML\<open>
structure Scholarly_paper_trace_invariant =
struct 
local

fun group f g cidS [] = []
   |group f g cidS (a::S) = case find_first (f a) cidS of
                            NONE => [a] :: group f g cidS S
                          | SOME cid => let val (pref,suff) =  chop_prefix  (g cid) S
                                        in (a::pref)::(group f g cidS suff) end;

fun partition ctxt cidS trace = 
    let fun find_lead (x,_) = DOF_core.is_subclass ctxt x;
        fun find_cont cid (cid',_) =  DOF_core.is_subclass ctxt cid' cid
    in group find_lead find_cont cidS trace end;

fun dest_option _ (Const (@{const_name "None"}, _)) = NONE
  | dest_option f (Const (@{const_name "Some"}, _) $ t) = SOME (f t)

in 

fun check ctxt cidS mon_id pos =
    let val trace  = AttributeAccess.compute_trace_ML ctxt mon_id pos @{here}
        val groups = partition (Context.proof_of ctxt) cidS trace
        fun get_level_raw oid = AttributeAccess.compute_attr_access ctxt "level" oid @{here} @{here};
        fun get_level oid = dest_option (snd o HOLogic.dest_number) (get_level_raw (oid));
        fun check_level_hd a = case (get_level (snd a)) of
                                  NONE => error("Invariant violation: leading section" ^ snd a ^ 
                                                " must have lowest level")
                                | SOME X => X
        fun check_group_elem level_hd a = case (get_level (snd a)) of
                                              NONE => true
                                            | SOME y => if level_hd <= y then true
                                                        (* or < ? But this is too strong ... *)
                                                        else error("Invariant violation: "^
                                                                   "subsequent section " ^ snd a ^ 
                                                                   " must have higher level.");
        fun check_group [] = true
           |check_group [_] = true
           |check_group (a::S) = forall (check_group_elem (check_level_hd a)) (S)
    in if forall check_group groups then () 
       else error"Invariant violation: leading section must have lowest level" 
    end
end

end
\<close>


setup\<open> let val cidS = ["scholarly_paper.introduction","scholarly_paper.technical", 
                       "scholarly_paper.example", "scholarly_paper.conclusion"];
           fun body moni_oid _ ctxt = (Scholarly_paper_trace_invariant.check 
                                                    ctxt cidS moni_oid @{here};
                                       true)
       in  DOF_core.update_class_invariant "scholarly_paper.article" body end\<close>

ML\<open> \<close>

section\<open>Miscelleous\<close>

subsection\<open>Common Abbreviations\<close>

define_shortcut* eg  \<rightleftharpoons> \<open>\eg\<close>  (* Latin: „exempli gratia“  meaning  „for example“. *)
                 ie  \<rightleftharpoons> \<open>\ie\<close>  (* Latin: „id est“  meaning „that is to say“. *)
                 etc \<rightleftharpoons> \<open>\etc\<close> (* Latin : „et cetera“ meaning „et cetera“ *)

subsection\<open>Layout Trimming Commands (with syntactic checks)\<close>

ML\<open> 
local

val scan_cm = Scan.ahead (Basic_Symbol_Pos.$$$ "c" |-- Basic_Symbol_Pos.$$$ "m" ) ;
val scan_pt = Scan.ahead (Basic_Symbol_Pos.$$$ "p" |-- Basic_Symbol_Pos.$$$ "t" ) ;
val scan_blank = Scan.repeat (   Basic_Symbol_Pos.$$$ " "
                              || Basic_Symbol_Pos.$$$ "\t" 
                              || Basic_Symbol_Pos.$$$ "\n");

val scan_latex_measure = (scan_blank
                          |-- Scan.option (Basic_Symbol_Pos.$$$ "-")
                          |-- Symbol_Pos.scan_nat 
                          |-- (Scan.option ((Basic_Symbol_Pos.$$$ ".") |-- Symbol_Pos.scan_nat))
                          |-- scan_blank
                          |-- (scan_cm || scan_pt)
                          |-- scan_blank
                         );
in           

fun check_latex_measure _ src  = 
         let val _ = ((Scan.catch scan_latex_measure (Symbol_Pos.explode(Input.source_content src)))
                     handle Fail _ => error ("syntax error in LaTeX measure") )
         in () end
end\<close>



setup\<open> DOF_lib.define_macro \<^binding>\<open>vs\<close>  "\\vspace{" "}" (check_latex_measure) \<close> 
setup\<open> DOF_lib.define_macro \<^binding>\<open>hs\<close>  "\\hspace{" "}" (check_latex_measure) \<close> 

(*<*)

text\<open>Tests: \<^vs>\<open>-0.14cm\<close>\<close>
ML\<open> check_latex_measure @{context} (Input.string "-3.14 cm") \<close>
define_macro* vs2 \<rightleftharpoons> \<open>\vspace{\<close> _ \<open>}\<close> (check_latex_measure) (* checkers NYI on Isar-level *)
define_macro* hs2 \<rightleftharpoons> \<open>\hspace{\<close> _ \<open>}\<close> (* works fine without checker.*)

(*>*)

define_shortcut* clearpage \<rightleftharpoons> \<open>\clearpage{}\<close>
                 hf \<rightleftharpoons> \<open>\hfill\<close> 
                 br \<rightleftharpoons> \<open>\break\<close> 

end

