(*<*)
theory "03_GuidedTour"
  imports "02_Background"
begin
(*>*)

chapter*[casestudies::example,main_author="Some(@{docitem ''adb''}::author)"]\<open> \isadof: A Guided Tour \<close>
   
text\<open> In this section, we will use the \isadof document ontology language
for three different application scenarios: for scholarly papers, for mathematical 
exam sheets as well as standardization documents where the concepts of the
standard are captured in the ontology. For space reasons, we will concentrate in all three
cases on aspects of the modeling due to space limitations.\<close>



section*[install::technical]\<open>Getting Started\<close>
text\<open>

DOWNLOAD INFO MISSING

INSTALLATION INFO MISSING

CREATING A PROJECT:

To start using \isadof, one creates an Isabelle project (with the name 
\inlinebash{IsaDofApplications}):
\begin{bash}
  isabelle DOF_mkroot -o scholarly_paper -t lncs -d  IsaDofApplications
\end{bash}
where the \inlinebash{-o scholarly_paper} specifies the ontology for writing scientific articles and 
\inlinebash{-t lncs} specifies the use of Springer's \LaTeX-configuration for the Lecture Notes in 
Computer Science series. The project can be formally checked, including the generation of the 
article in PDF using the  following command:
\begin{bash}
  isabelle build -d . IsaDofApplications
\end{bash}
\<close>


section*[scholar_onto::example]\<open> The Scholar Paper Scenario: Eating One's Own Dog Food. \<close>  
text\<open> The following ontology is a simple ontology modeling scientific papers. In this 
\isadof application scenario, we deliberately refrain from integrating references to
(Isabelle) formal content in order  demonstrate that \isadof is not a framework from 
Isabelle users to Isabelle users only.
Of course, such references can be added easily and represent a particular strength  
of \isadof.


\begin{figure}
\begin{isar}
doc_class title =
   short_title :: "string option"  <=  None
     
doc_class subtitle =
   abbrev :: "string option"       <=  None

doc_class author =
   affiliation :: "string"

doc_class abstract =
   keyword_list :: "string list"  <= None

doc_class text_section = 
   main_author :: "author option"  <=  None
   todo_list   :: "string list"    <=  "[]"
\end{isar}
\caption{The core of the ontology definition for writing scholarly papers.}
\label{fig:paper-onto-core}
\end{figure}
The first part of the ontology \inlineisar+scholarly_paper+ (see \autoref{fig:paper-onto-core})
contains the document class definitions
with the usual text-elements of a scientific paper. The attributes \inlineisar+short_title+, 
\inlineisar+abbrev+ etc are introduced with their types as well as their default values.
Our model prescribes an optional \inlineisar+main_author+ and a todo-list attached to an arbitrary 
text section; since instances of this class are mutable (meta)-objects of text-elements, they
can be modified arbitrarily through subsequent text and of course globally during text evolution.
Since \inlineisar+author+ is a HOL-type internally generated by \isadof framework and can therefore
appear in the \inlineisar+main_author+ attribute of the \inlineisar+text_section+ class; 
semantic links between concepts can be modeled this way.

The translation of its content to, \eg, Springer's \LaTeX{} setup for the Lecture Notes in Computer 
Science Series, as required by many scientific conferences, is mostly straight-forward. \<close>

figure*[fig1::figure,spawn_columns=False,relative_width="95",src="''figures/Dogfood-Intro''"]
       \<open> Ouroboros I: This paper from inside \ldots \<close>  

text\<open> @{docitem \<open>fig1\<close>} shows the corresponding view in the Isabelle/PIDE of thqqe present paper.
Note that the text uses \isadof's own text-commands containing the meta-information provided by
the underlying ontology.
We proceed by a definition of \inlineisar+introduction+'s, which we define as the extension of
\inlineisar+text_section+ which is intended to capture common infrastructure:
\begin{isar}
doc_class introduction = text_section +
   comment :: string
\end{isar}
As a consequence of the definition as extension, the \inlineisar+introduction+ class
inherits the attributes \inlineisar+main_author+ and \inlineisar+todo_list+ together with 
the corresponding default values.

As a variant of the introduction, we could add here an attribute that contains the formal 
claims of the article --- either here, or, for example, in the keyword list of the abstract. 
As type, one could use either the built-in type \inlineisar+term+ (for syntactically correct, 
but not necessarily proven entity) or \inlineisar+thm+ (for formally proven entities). It suffices 
to add the line:
\begin{isar}
   claims  :: "thm list"
\end{isar}
and to extent the \LaTeX-style accordingly to handle the additional field. 
Note that \inlineisar+term+ and \inlineisar+thm+ are types reflecting the core-types of the
Isabelle kernel. In a corresponding conclusion section, one could model analogously an 
achievement section; by programming a specific compliance check in SML, the implementation 
of automated forms of validation check for specific categories of papers is envisageable. 
Since this requires deeper knowledge in Isabelle programming, however, we consider this out 
of the scope of this paper.


We proceed more or less conventionally by the subsequent sections (\autoref{fig:paper-onto-sections})
\begin{figure}
\begin{isar}
doc_class technical = text_section +
   definition_list :: "string list" <=  "[]"

doc_class example   = text_section +
   comment :: string

doc_class conclusion = text_section +
   main_author :: "author option"  <=  None
   
doc_class related_work = conclusion +
   main_author :: "author option"  <=  None

doc_class bibliography =
   style :: "string option"  <=  "''LNCS''"
\end{isar}
\caption{Various types of sections of a scholarly papers.}
\label{fig:paper-onto-sections}
\end{figure}
 and finish with a monitor class definition that enforces a textual ordering
in the document core by a regular expression (\autoref{fig:paper-onto-monitor}).
\begin{figure}
\begin{isar}
doc_class article = 
   trace :: "(title + subtitle + author+ abstract +
              introduction + technical + example +
              conclusion + bibliography) list"
   where "(title       ~~ \<lbrakk>subtitle\<rbrakk>   ~~ \<lbrace>author\<rbrace>$^+$+  ~~  abstract    ~~
             introduction ~~  \<lbrace>technical || example\<rbrace>$^+$  ~~  conclusion ~~  
             bibliography)"
\end{isar}
\caption{A monitor for the scholarly paper ontology.}
\label{fig:paper-onto-monitor}
\end{figure}
\<close>
text\<open> We might wish to add a component into our ontology that models figures to be included into 
the document. This boils down to the exercise of modeling structured data in the style of a 
functional programming language in HOL and to reuse the implicit HOL-type inside a suitable document 
class \inlineisar+figure+:
\begin{isar}
datatype placement = h | t | b | ht | hb   
doc_class figure   = text_section +
   relative_width   :: "int" (* percent of textwidth *)    
   src     :: "string"
   placement :: placement 
   spawn_columns :: bool <= True 
\end{isar}
\<close>

text\<open> Alternatively, by including the HOL-libraries for rationals, it is possible to 
use fractions or even mathematical reals. This must be counterbalanced by syntactic 
and semantic convenience. Choosing the mathematical reals, \eg, would have the drawback that 
attribute evaluation could be substantially more complicated.\<close>

figure*[fig_figures::figure,spawn_columns=False,relative_width="85",src="''figures/Dogfood-figures''"]
       \<open> Ouroboros II: figures \ldots \<close>

text\<open> The document class \inlineisar+figure+ --- supported by the \isadof text command 
\inlineisar+figure*+ --- makes it possible to express the pictures and diagrams in this paper 
such as @{docitem_ref \<open>fig_figures\<close>}.
\<close>
     

section*[cenelec_onto::example]\<open> The Certification Scenario following CENELEC \<close>
text\<open> Documents to be provided in formal certifications (such as CENELEC
50126/50128, the DO-178B/C, or Common Criteria) can much profit from the control of ontological consistency: 
a lot of an evaluators work consists in tracing down the links from requirements over 
assumptions down to elements of evidence, be it in the models, the code, or the tests. 
In a certification process, traceability becomes a major concern; and providing
mechanisms to ensure complete traceability already at the development of the
global document will clearly increase speed and reduce risk and cost of a
certification process. Making the link-structure machine-checkable, be it between requirements, 
assumptions, their implementation and their discharge by evidence (be it tests, proofs, or
authoritative arguments), is therefore natural and has the potential to decrease the cost 
of developments targeting certifications. Continuously checking the links between the formal
and the semi-formal parts of such documents is particularly valuable during the (usually
collaborative) development effort. 

As in many other cases, formal certification documents come with an own terminology and
pragmatics of what has to be demonstrated and where, and how the trace-ability of requirements through
design-models over code to system environment assumptions has to be assured.  
\<close>
text\<open> In the sequel, we present a simplified version of an ontological model used in a 
case-study~ @{cite "bezzecchi.ea:making:2018"}. We start with an introduction of the concept of requirement 
(see \autoref{fig:conceptual}). 
\begin{figure}
\begin{isar}
doc_class requirement = long_name :: "string option"

doc_class requirement_analysis = no :: "nat"
   where "requirement_item +"

doc_class hypothesis = requirement +
      hyp_type :: hyp_type <= physical  (* default *)
  
datatype ass_kind = informal | semiformal | formal
  
doc_class assumption = requirement +
     assumption_kind :: ass_kind <= informal 
\end{isar}
\caption{Modeling requirements.}
\label{fig:conceptual}
\end{figure}
Such ontologies can be enriched by larger explanations and examples, which may help
the team of engineers substantially when developing the central document for a certification, 
like an explication what is precisely the difference between an \<^emph>\<open>hypothesis\<close> and an 
\<^emph>\<open>assumption\<close> in the context of the evaluation standard. Since the PIDE makes for each 
document class its definition available by a simple mouse-click, this kind on meta-knowledge 
can be made far more accessible during the document evolution.

For example, the term of category \<^emph>\<open>assumption\<close> is used for domain-specific assumptions. 
It has formal, semi-formal and informal sub-categories. They have to be 
tracked and discharged by appropriate validation procedures within a 
certification process, by it by test or proof. It is different from a hypothesis, which is
globally assumed and accepted.

In the sequel, the category \<^emph>\<open>exported constraint\<close> (or \<^emph>\<open>ec\<close> for short)
is used for formal assumptions, that arise during the analysis,
design or implementation and have to be tracked till the final
evaluation target, and discharged by appropriate validation procedures 
within the certification process, by it by test or proof.  A particular class of interest 
is the category \<^emph>\<open>safety related application condition\<close> (or \<^emph>\<open>srac\<close> 
for short) which is used for \<^emph>\<open>ec\<close>'s that establish safety properties
of the evaluation target. Their track-ability throughout the certification
is therefore particularly critical. This is naturally modeled as follows:
\begin{isar}  
doc_class ec = assumption  +
     assumption_kind :: ass_kind <= (*default *) formal
                        
doc_class srac = ec  +
     assumption_kind :: ass_kind <= (*default *) formal
\end{isar}
\<close>

section*[math_exam::example]\<open> The Math-Exam Scenario \<close> 
text\<open> The Math-Exam Scenario is an application with mixed formal and 
semi-formal content. It addresses applications where the author of the exam is not present 
during the exam and the preparation requires a very rigorous process, as the french 
\<^emph>\<open>baccaleaureat\<close> and exams at The University of Sheffield.

We assume that the content has four different types of addressees, which have a different
\<^emph>\<open>view\<close> on the integrated document: 

\<^item> the \<^emph>\<open>setter\<close>, \ie, the author of the exam,
\<^item> the \<^emph>\<open>checker\<close>, \ie, an internal person that checks 
  the exam for feasibility and non-ambiguity, 
\<^item> the \<^emph>\<open>external examiner\<close>, \ie, an external person that checks 
  the exam for feasibility and non-ambiguity, and 
\<^item> the \<^emph>\<open>student\<close>, \ie, the addressee of the exam. 
\<close>
text\<open> The latter quality assurance mechanism is used in many universities,
where for organizational reasons the execution of an exam takes place in facilities
where the author of the exam is not expected to be physically present.
Furthermore, we assume a simple grade system (thus, some calculation is required). 

\begin{figure}
\begin{isar}
doc_class Author = ...
datatype Subject =  algebra | geometry | statistical
datatype Grade =  A1 | A2 | A3

doc_class Header =  examTitle   :: string
                    examSubject :: Subject
                    date        :: string
                    timeAllowed :: int --  minutes

datatype ContentClass =  setter
                      | checker 
                      | external_examiner   
                      | student   

doc_class Exam_item = 
  concerns :: "ContentClass set"  

doc_class Exam_item = 
  concerns :: "ContentClass set"  

type_synonym SubQuestion = string
\end{isar}
\caption{The core of the ontology modeling math exams.}
\label{fig:onto-exam}
\end{figure}
The heart of this ontology (see \autoref{fig:onto-exam}) is an alternation of questions and answers, 
where the answers can consist of simple yes-no answers (QCM style check-boxes) or lists of formulas. 
Since we do not
assume familiarity of the students with Isabelle (\inlineisar+term+ would assume that this is a 
parse-able and type-checkable entity), we basically model a derivation as a sequence of strings
(see \autoref{fig:onto-questions}).
\begin{figure}
\begin{isar}
doc_class Answer_Formal_Step =  Exam_item +
  justification :: string
  "term"        :: "string" 
  
doc_class Answer_YesNo =  Exam_item +
  step_label :: string
  yes_no     :: bool  -- \<open>for checkboxes\<close>

datatype Question_Type =   
  formal | informal | mixed 
  
doc_class Task = Exam_item +
  level    :: Level
  type     :: Question_Type
  subitems :: "(SubQuestion * 
                   (Answer_Formal_Step list + Answer_YesNo) list) list"
  concerns :: "ContentClass set" <= "UNIV" 
  mark     :: int
doc_class Exercise = Exam_item +
  type     :: Question_Type
  content  :: "(Task) list"
  concerns :: "ContentClass set" <= "UNIV" 
  mark     :: int
\end{isar}
\caption{An exam can contain different types of questions.}
\label{fig:onto-questions}
\end{figure}

In many institutions, it makes sense to have a rigorous process of validation
for exam subjects: is the initial question correct? Is a proof in the sense of the
question possible? We model the possibility that the @{term examiner} validates a 
question by a sample proof validated by Isabelle (see \autoref{fig:onto-exam-monitor}). 
In our scenario this sample proofs are completely \<^emph>\<open>intern\<close>, \ie, not exposed to the 
students but just additional material for the internal review process of the exam.
\begin{figure}
\begin{isar}
doc_class Validation = 
   tests  :: "term list"  <="[]"
   proofs :: "thm list"   <="[]"
  
doc_class Solution = Exam_item +
  content  :: "Exercise list"
  valids   :: "Validation list"
  concerns :: "ContentClass set" <= "{setter,checker,external_examiner}"
  
doc_class MathExam=
  content :: "(Header + Author + Exercise) list"
  global_grade :: Grade 
  where "\<lbrace>Author\<rbrace>$^+$  ~~  Header ~~  \<lbrace>Exercise ~~ Solution\<rbrace>$^+$ "
\end{isar}
\caption{Validating exams.}
\label{fig:onto-exam-monitor}
\end{figure}
\<close>

  
declare_reference*["fig_qcm"::figure]

text\<open> Using the \LaTeX{} package hyperref, it is possible to conceive an interactive 
exam-sheets with multiple-choice and/or free-response elements 
(see @{docitem_ref (unchecked) \<open>fig_qcm\<close>}). With the 
help of the latter, it is possible that students write in a browser a formal mathematical 
derivation---as part of an algebra exercise, for example---which is submitted to the examiners 
electronically. \<close>
figure*[fig_qcm::figure,spawn_columns=False,
        relative_width="90",src="''figures/InteractiveMathSheet''"]
        \<open> A Generated QCM Fragment \ldots \<close>  


section*[ontopide::technical]\<open> Ontology-based IDE support \<close>  
text\<open> We present a selection of interaction scenarios  @{example \<open>scholar_onto\<close>}
and @{example \<open>cenelec_onto\<close>} with Isabelle/PIDE instrumented by \isadof. \<close>

subsection*[scholar_pide::example]\<open> A Scholarly Paper \<close>  
text\<open> In \autoref{fig-Dogfood-II-bgnd1} and \autoref{fig-bgnd-text_section} we show how
hovering over links permits to explore its meta-information. 
Clicking on a document class identifier permits to hyperlink into the corresponding
class definition (\autoref{fig:Dogfood-IV-jumpInDocCLass}); hovering over an attribute-definition
(which is qualified in order to disambiguate; \autoref{fig:Dogfood-V-attribute}).
\<close>

open_monitor*["text-elements"::figure_group,
              caption="''Exploring text elements.''"]

figure*["fig-Dogfood-II-bgnd1"::figure, spawn_columns=False,
        relative_width="48",
        src="''figures/Dogfood-II-bgnd1''"]
       \<open>Exploring a Reference of a Text-Element.\<close>

figure*["fig-bgnd-text_section"::figure, spawn_columns=False,
        relative_width="48",
        src="''figures/Dogfood-III-bgnd-text_section''"]
       \<open>Exploring the class of a text element.\<close>

close_monitor*["text-elements"]


side_by_side_figure*["hyperlinks"::side_by_side_figure,anchor="''fig:Dogfood-IV-jumpInDocCLass''",
                      caption="''Hyperlink to Class-Definition.''",relative_width="48",
                      src="''figures/Dogfood-IV-jumpInDocCLass''",anchor2="''fig:Dogfood-V-attribute''",
                      caption2="''Exploring an attribute.''",relative_width2="47",
                      src2="''figures/Dogfood-III-bgnd-text_section''"]\<open> Hyperlinks.\<close>


declare_reference*["figDogfoodVIlinkappl"::figure]
text\<open> An ontological reference application in \autoref{figDogfoodVIlinkappl}: the ontology-dependant 
antiquotation \inlineisar|@ {example ...}| refers to the corresponding text-elements. Hovering allows 
for inspection, clicking for jumping to the definition.  If the link does not exist or has a 
non-compatible type, the text is not validated.  \<close>

figure*[figDogfoodVIlinkappl::figure,relative_width="80",src="''figures/Dogfood-V-attribute''"]
       \<open> Exploring an attribute (hyperlinked to the class). \<close> 
subsection*[cenelec_pide::example]\<open> CENELEC  \<close>
declare_reference*[figfig3::figure]  
text\<open> The corresponding view in @{docitem_ref (unchecked) \<open>figfig3\<close>} shows core part of a document,  
coherent to the @{example \<open>cenelec_onto\<close>}. The first sample shows standard Isabelle antiquotations 
@{cite "wenzel:isabelle-isar:2017"} into formal entities of a theory. This way, the informal parts 
of a document get ``formal content'' and become more robust under change.\<close>

figure*[figfig3::figure,relative_width="80",src="''figures/antiquotations-PIDE''"]
\<open> Standard antiquotations referring to theory elements.\<close>

declare_reference*[figfig5::figure]  
text\<open> The subsequent sample in @{docitem_ref (unchecked) \<open>figfig5\<close>} shows the definition of an 
\<^emph>\<open>safety-related application condition\<close>, a side-condition of a theorem which 
has the consequence that a certain calculation must be executed sufficiently fast on an embedded 
device. This condition can not be established inside the formal theory but has to be 
checked by system integration tests.\<close>
  
figure*[figfig5::figure, relative_width="80", src="''figures/srac-definition''"]
        \<open> Defining a SRAC reference \ldots \<close>
figure*[figfig7::figure, relative_width="80", src="''figures/srac-as-es-application''"]
        \<open> Using a SRAC as EC document reference. \<close>
       
text\<open> Now we reference in @{docitem_ref (unchecked) \<open>figfig7\<close>} this safety-related condition; 
however, this happens in a context where general \<^emph>\<open>exported constraints\<close> are listed. 
\isadof's checks establish that this is legal in the given ontology. 

This example shows that ontological modeling is indeed adequate for large technical,
collaboratively developed documentations, where modifications can lead easily to incoherence. 
The current checks help to systematically avoid this type of incoherence between formal and 
informal parts. \<close>    



(*<*)
end
(*>*) 
  