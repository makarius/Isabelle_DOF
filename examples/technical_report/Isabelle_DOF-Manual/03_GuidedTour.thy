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

(*<*)
theory 
    "03_GuidedTour"
  imports 
    "02_Background"
    "Isabelle_DOF.CENELEC_50128"
begin
(*>*)

chapter*[isadof_tour::text_section]\<open>\<^isadof>: A Guided Tour\<close>

text\<open>
  In this chapter, we will give a introduction into using \<^isadof> for users that want to create and 
  maintain documents following an existing document ontology.
\<close>

section*[getting_started::technical]\<open>Getting Started\<close>
text\<open>
As an alternative to installing \<^isadof>{} locally, the latest official release  \<^isadof> is also 
available on \href{https://cloud.docker.com/u/logicalhacking/}{Docker Hub}. Thus, if you have 
\href{https://www.docker.com}{Docker} installed and 
your installation of Docker supports X11 application, you can start \<^isadof> as follows:

@{boxed_bash [display] 
\<open>ë\prompt{}ë docker run -ti --rm -e DISPLAY=$DISPLAY \
   -v /tmp/.X11-unix:/tmp/.X11-unix \ 
   logicalhacking/isabelle_dof-ë\doflatestversionë_ë\MakeLowercase{\isabellelatestversion}ë \
   isabelle jedit
\<close>}
\<close>

subsection*[installation::technical]\<open>Installation\<close>
text\<open>
  In this section, we will show how to install \<^isadof> and its pre-requisites: Isabelle and 
  \<^LaTeX>. We assume a basic familiarity with a Linux/Unix-like command line (i.e., a shell). 
\<close>

subsubsection*[prerequisites::technical]\<open>Pre-requisites\<close>
text\<open>
  \<^isadof> has to major pre-requisites: 
  \<^item> \<^bold>\<open>Isabelle\<close>\<^bindex>\<open>Isabelle\<close> (\isabellefullversion). 
    \<^isadof> uses a two-part version system (e.g., 1.0.0/2020),  where the first part is the version
    of \<^isadof> (using semantic versioning) and the second part is the supported version of Isabelle. 
    Thus, the same version of \<^isadof> might be available for different versions of Isabelle. 
  \<^item> \<^bold>\<open>\<^TeXLive> 2020\<close>\<^bindex>\<open>TexLive@\<^TeXLive>\<close> (or any other modern  \<^LaTeX>-distribution where
    \<^pdftex> supports the \<^boxed_latex>\<open>\expanded\<close>  primitive).
    \<^footnote>\<open>see \<^url>\<open>https://www.texdev.net/2018/12/06/a-new-primitive-expanded\<close>\<close>
\<close>

paragraph\<open>Installing Isabelle\<close>
text\<open>
%\enlargethispage{\baselineskip}
  Please download and install the Isabelle \isabelleversion distribution for your operating system 
  from the \href{\isabelleurl}{Isabelle website} (\url{\isabelleurl}). After the successful 
  installation of Isabelle, you should be able to call the \<^boxed_bash>\<open>isabelle\<close> tool on the 
  command line:

\begin{bash}
ë\prompt{}ë isabelle version
ë\isabellefullversionë
\end{bash}
% bu : do not know why this does not work here ...
%@ {boxed_bash [display]\<open>
%ë\prompt{}ë isabelle version
%ë\isabellefullversionë
%\<close>}

Depending on your operating system and depending if you put Isabelle's  \<^boxed_bash>\<open>bin\<close> directory
in your  \<^boxed_bash>\<open>PATH\<close>, you will need to invoke  \<^boxed_bash>\<open>isabelle\<close> using its
full qualified path, \<^eg>:

\begin{bash}
ë\prompt{}ë /usr/local/Isabelleë\isabelleversion/ëbin/isabelle version
ë\isabellefullversionë
\end{bash}

%@ {boxed_bash [display]\<open>
%ë\prompt{}ë /usr/local/Isabelleë\isabelleversion/ëbin/isabelle version
%ë\isabellefullversionë
%\<close>}
\<close>

paragraph\<open>Installing \<^TeXLive>\<close>
text\<open>
  Modern Linux distribution will allow you to install \<^TeXLive> using their respective package 
  managers. On a modern Debian system or a Debian derivative (\<^eg>, Ubuntu), the following command 
  should install all required \<^LaTeX> packages:

\begin{bash}
ë\prompt{}ë sudo aptitude install texlive-latex-extra texlive-fonts-extra
\end{bash}
%@ {boxed_bash [display]\<open>
%ë\prompt{}ë sudo aptitude install texlive-latex-extra texlive-fonts-extra
%\<close>}

  Please check that this, indeed, installs a version of \<^pdftex> that supports the 
  \<^boxed_latex>\<open>\expanded\<close>. To check your \<^pdftex>-binary, execute 

\begin{bash}
ë\prompt{}ë pdftex \\expanded{Success}\\end
This is pdfTeX, Version 3.14159265-2.6-1.40.20 (TeX Live 2019/Debian).
Output written on texput.pdf (1 page, 8650 bytes).
Transcript written on texput.log.
\end{bash}
%@ {boxed_bash [display]\<open>
%ë\prompt{}ë pdftex \\expanded{Success}\\end
%This is pdfTeX, Version 3.14159265-2.6-1.40.20 (TeX Live 2019/Debian).
%Output written on texput.pdf (1 page, 8650 bytes).
%Transcript written on texput.log.
%\<close>}

  If this generates successfully a file \inlinebash|texput.pdf|, your \<^pdftex>-binary supports
  the \<^boxed_latex>\<open>\expanded\<close>-primitive. If your Linux distribution does not (yet) ship \<^TeXLive> 
  2019 or your are running Windows or OS X, please follow the installation instructions from 
  \<^url>\<open>https://www.tug.org/texlive/acquire-netinstall.html\<close>. 
\<close>

subsubsection*[isadof::technical]\<open>Installing \<^isadof>\<close>
text\<open>
  In the following, we assume that you already downloaded the \<^isadof> distribution 
  (\href{\isadofarchiveurl}{\isadofarchiven}) from the \<^isadof> web site. The main steps for 
  installing are extracting the \<^isadof> distribution and calling its \inlinebash|install| script. 
  We start by extracting the \<^isadof> archive:

\begin{bash}
ë\prompt{}ë tar xf ë\href{\isadofarchiveurl}{\isadofarchiven}ë
\end{bash}
This will create a directory \texttt{\isadofdirn} containing \<^isadof> distribution.
Next, we need to invoke the \<^boxed_bash>\<open>install\<close> script. If necessary, the installations 
automatically downloads additional dependencies from the AFP (\<^url>\<open>https://www.isa-afp.org\<close>), 
namely the AFP  entries ``Functional Automata''~@{cite "nipkow.ea:functional-Automata-afp:2004"} 
and ``Regular Sets and Expressions''~@{cite "kraus.ea:regular-sets-afp:2010"}. This might take a 
few minutes to complete. Moreover, the installation script applies a patch to the Isabelle system, 
which requires  \<^emph>\<open>write permissions for the Isabelle system directory\<close> and registers \<^isadof> as 
Isabelle component. 

If the \<^boxed_bash>\<open>isabelle\<close> tool is not in your  \<^boxed_bash>\<open>PATH\<close>, you need to call the 
 \<^boxed_bash>\<open>install\<close> script with the  \<^boxed_bash>\<open>--isabelle\<close> option, passing the full-qualified
path of the \<^boxed_bash>\<open>isabelle\<close> tool ( \<^boxed_bash>\<open>install --help\<close> gives 
you an overview of all available configuration options):

\begin{bash}
ë\prompt{}ë cd ë\isadofdirnë
ë\prompt{\isadofdirn}ë ./install --isabelle /usr/local/Isabelleë\isabelleversion/bin/isabelleë

Isabelle/DOF Installer
======================
* Checking Isabelle version:
  Success: found supported Isabelle version ë(\isabellefullversion)ë
* Checking (La)TeX installation:
  Success: pdftex supports \expanded{} primitive.
* Check availability of Isabelle/DOF patch:
  Warning: Isabelle/DOF patch is not available or outdated.
           Trying to patch system ....
       Applied patch successfully, Isabelle/HOL will be rebuilt during
       the next start of Isabelle.
* Checking availability of AFP entries:
  Warning: could not find AFP entry Regular-Sets.
  Warning: could not find AFP entry Functional-Automata.
           Trying to install AFP (this might take a few *minutes*) ....
           Registering Regular-Sets iëën 
                 /home/achim/.isabelle/Isabelleë\isabelleversion/ROOTSë
           Registering Functional-Automata iëën 
                 /home/achim/.isabelle/Isabelleë\isabelleversion/ROOTSë
           AFP installation successful.
* Searching fëëor existing installation:
  No old installation found.
* Installing Isabelle/DOF
  - Installing Tools iëën 
        /home/achim/.isabelle/Isabelleë\isabelleversion/DOF/Toolsë
  - Installing document templates iëën 
        /home/achim/.isabelle/Isabelleë\isabelleversion/DOF/document-templateë
  - Installing LaTeX styles iëën 
       /home/achim/.isabelle/Isabelleë\isabelleversion/DOF/latexë
  - Registering Isabelle/DOF
    * Registering tools iëën 
       /home/achim/.isabelle/Isabelleë\isabelleversion/etc/settingsë
* Installation successful. Enjoy Isabelle/DOF, you can build the session
  Isabelle/DOF and all example documents by executing:
  /usr/local/Isabelleë\isabelleversion/bin/isabelleë build -D .
\end{bash}

After the successful installation, you can now explore the examples (in the sub-directory 
\inlinebash|examples| or create your own project. On the first start, the session 
\inlinebash|Isabelle_DOF| will be built automatically. If you want to pre-build this 
session and all example documents, execute:

\begin{bash}
ë\prompt{\isadofdirn}ë isabelle build -D . 
\end{bash}
\<close>

subsection*[first_project::technical]\<open>Creating an \<^isadof> Project\<close>
text\<open>
  \<^isadof> provides its own variant of Isabelle's 
  \inlinebash|mkroot| tool, called \inlinebash|mkroot_DOF|:\index{mkroot\_DOF}

\begin{bash} 
ë\prompt{}ë isabelle mkroot_DOF -h 

Usage: isabelle mkroot_DOF [OPTIONS] [DIR]

  Options are:
    -h           print this hëëelp text and exëëit
    -n NAME      alternative session name (default: DIR base name)
    -o ONTOLOGY  (default: scholarly_paper)
       Available ontologies:
       * CENELEC_50128
       * math_exam
       * scholarly_paper
       * technical_report
    -t TEMPLATE   (default: scrartcl)
       Available document templates:
       * lncs
       * scrartcl
       * scrreprt-modern
       * scrreprt

  Prepare session root DIR (default: current directory).
\end{bash} 

  Creating a new document setup requires two decisions:
  \<^item> which ontologies (\<^eg>, scholarly\_paper) are required and 
  \<^item> which document template (layout)\index{document template} should be used 
    (\<^eg>, scrartcl\index{scrartcl}). Some templates (\<^eg>, lncs) require that the users manually 
    obtains and adds the necessary \<^LaTeX> class file (\<^eg>, \inlinebash|llncs.cls|. 
    This is mostly due to licensing restrictions.
\<close>
text\<open>
  If you are happy with the defaults, \ie, using the ontology for writing academic papers 
  (scholarly\_paper) using a report layout based on the article class (\inlineltx|scrartcl|) of 
  the KOMA-Script bundle~@{cite "kohm:koma-script:2019"}, you can create your first project 
  \inlinebash|myproject| as follows:

\begin{bash}
ë\prompt{}ë isabelle mkroot_DOF myproject

Preparing session "myproject" iëën "myproject"
  creating "myproject/ROOT"
  creating "myproject/document/root.tex"

Now use the following coëëmmand line to build the session:
  isabelle build -D myproject
\end{bash}

  This creates a directory \inlinebash|myproject| containing the \<^isadof>-setup for your 
  new document. To check the document formally, including the generation of the document in PDF,
  you only need to execute

\begin{bash}
ë\prompt{}ë  isabelle build -d . myproject
\end{bash}

This will create the directory \inlinebash|myproject|: 
\begin{center}
\begin{minipage}{.9\textwidth}
\dirtree{%
.1 .
.2 myproject.
.3 document.
.4 build\DTcomment{Build Script}.
.4 isadof.cfg\DTcomment{\<^isadof> configuraiton}.
.4 preamble.tex\DTcomment{Manual \<^LaTeX>-configuration}.
.3 ROOT\DTcomment{Isabelle build-configuration}.
}
\end{minipage}
\end{center}
The \<^isadof> configuration (\inlinebash|isadof.cfg|) specifies the required
ontologies and the document template using a YAML syntax.\<^footnote>\<open>Isabelle power users will recognize that 
\<^isadof>'s document setup does not make use of a file \inlinebash|root.tex|: this file is 
replaced by built-in document templates.\<close> The main two configuration files for 
users are:
\<^item> The file \<^boxed_bash>\<open>ROOT\<close>\<^index>\<open>ROOT\<close>, which defines the Isabelle session. New theory files as well as new 
  files required by the document generation (\<^eg>, images, bibliography database using \<^BibTeX>, local
  \<^LaTeX>-styles) need to be registered in this file. For details of Isabelle's build system, please 
  consult the Isabelle System Manual~@{cite "wenzel:system-manual:2020"}.
\<^item> The file \<^boxed_bash>\<open>praemble.tex\<close>\<^index>\<open>praemble.tex\<close>, which allows users to add additional 
  \<^LaTeX>-packages or to add/modify \<^LaTeX>-commands. 
\<close>

section*[scholar_onto::example]\<open>Writing Academic Publications in \<^boxed_theory_text>\<open>scholarly_paper\<close>)\<close>  
subsection\<open>Papers in freeform-style\<close>
text\<open> 
  The ontology \<^boxed_theory_text>\<open>scholarly_paper\<close>
  \<^index>\<open>ontology!scholarly\_paper\<close> is an ontology modeling 
  academic/scientific papers, with a slight bias to texts in the domain of mathematics and engineering. 
  We explain first the principles of its underlying ontology, and then we present two ''real'' 
  example instances of our own.
\<close>
text\<open>
  \<^enum> The iFM 2020 paper~@{cite "taha.ea:philosophers:2020"} is a typical mathematical text,
    heavy in definitions with complex  mathematical notation and a lot of non-trivial cross-referencing
    between statements, definitions and proofs which is ontologically tracked. However, wrt.
    to the possible linking between the underlying formal theory and this mathematical presentation,
    it follows a pragmatic path without any ``deep'' linking to types, terms and theorems, 
    deliberately not exploiting \<^isadof> 's full potential with this regard.
  \<^enum> In the CICM 2018 paper~@{cite "brucker.ea:isabelle-ontologies:2018"}, we deliberately
    refrain from integrating references to formal content in order  demonstrate that \<^isadof> is not 
    a  framework from Isabelle users to Isabelle users only, but people just avoiding as much as
    possible \<^LaTeX> notation.

  The \<^isadof> distribution contains both examples using the ontology \<^verbatim>\<open>scholarly_paper\<close> in 
  the directory \nolinkurl{examples/scholarly_paper/2018-cicm-isabelle_dof-applications/} or
  \nolinkurl{examples/scholarly_paper/2020-ifm-csp-applications/}.

  You can inspect/edit the example in Isabelle's IDE, by either 
  \<^item> starting Isabelle/jedit using your graphical user interface (\<^eg>, by clicking on the 
    Isabelle-Icon provided by the Isabelle installation) and loading the file 
    \nolinkurl{examples/scholarly_paper/2018-cicm-isabelle_dof-applications/IsaDofApplications.thy}.
  \<^item> starting Isabelle/jedit from the command line by,\<^eg>, calling:

    \begin{bash}
ë\prompt{\isadofdirn}ë 
  isabelle jedit examples/scholarly_paper/2018-cicm-isabelle_dof-applications/\
  IsaDofApplications.thy
\end{bash}
\<close> 
(* We should discuss if we shouldn't put the iFM paper more in the foreground *) 

text\<open>    You can build the PDF-document at the command line by calling:

@{boxed_bash [display]
\<open>ë\prompt{}ë isabelle build \
2018-cicm-isabelle_dof-applications\<close>}
\<close>

subsection*[sss::technical]\<open>A Bluffers Guide to the \<^verbatim>\<open>scholarly_paper\<close> Ontology\<close>
text\<open> In this section we give a minimal overview of the ontology formalized in
      @{theory \<open>Isabelle_DOF.scholarly_paper\<close>}.\<close>

text\<open>  We start by modeling the usual text-elements of an academic paper: the title and author 
  information, abstract, and text section: 
@{theory_text [display]
\<open>doc_class title =
   short_title :: "string option"  <=  "None"
    
doc_class subtitle =
   abbrev ::      "string option"   <=  "None"
   
doc_class author =
   email       :: "string" <= "''''"
   http_site   :: "string" <= "''''"
   orcid       :: "string" <= "''''"
   affiliation :: "string"

doc_class abstract =
   keywordlist        :: "string list"   <= "[]" 
   principal_theorems :: "thm list"\<close>}
\<close>

text\<open>Note \<open>short_title\<close> and \<open>abbrev\<close> are optional and have the default \<open>None\<close> (no value).
Note further, that abstracts may have a \<open>principal_theorems\<close> list, where the built-in \<^isadof> type
\<open>thm list\<close> which contain references to formally proven theorems that must exist in the logical
context of this document; this is a decisive feature of \<^isadof> that conventional ontological
languages lack.\<close>

text\<open>We continue by the introduction of a main class: the text-element \<open>text_section\<close> (in contrast
to \<open>figure\<close> or \<open>table\<close> or similar. Note that
the \<open>main_author\<close> is typed with the class \<open>author\<close>, a HOL type that is automatically derived from
the document class definition \<open>author\<close> shown above. It is used to express which author currently
``owns'' this \<open>text_section\<close>, an information that can give rise to presentational or even
access-control features in a suitably adapted front-end.
 
@{theory_text [display] \<open>
doc_class text_section = text_element +
   main_author :: "author option"  <=  None
   fixme_list  :: "string list"    <=  "[]" 
   level       :: "int  option"    <=  "None"
\<close>}

The \<open>level\<close>-attibute \<^index>\<open>level\<close> enables doc-notation support for headers, chapters, sections, and 
subsections; we follow here the \<^LaTeX> terminology on levels to which \<^isadof> is currently targeting at.
The values are interpreted accordingly to the \<^LaTeX> standard.

\<^enum> part          \<^index>\<open>part\<close>          \<^bigskip>\<^bigskip>  \<open>Some -1\<close>
\<^enum> chapter       \<^index>\<open>chapter\<close>       \<^bigskip>\<^bigskip>  \<open>Some 0\<close> 
\<^enum> section       \<^index>\<open>section\<close>       \<^bigskip>\<^bigskip>  \<open>Some 1\<close> 
\<^enum> subsection    \<^index>\<open>subsection\<close>    \<^bigskip>\<^bigskip>  \<open>Some 2\<close> 
\<^enum> subsubsection \<^index>\<open>subsubsection\<close> \<^bigskip>\<^bigskip>  \<open>Some 3\<close> 

Additional means assure that the following invariant is maintained in a document 
conforming to @{theory \<open>Isabelle_DOF.scholarly_paper\<close>}:

\center {\<open>level > 0\<close>}
\<close>

text\<open> The rest of the ontology introduces concepts for \<open>introductions\<close>, \<open>conclusion\<close>, \<open>related_work\<close>,
\<open>bibliography\<close> etc. More details can be found in \<close>

subsection\<open>Writing Academic Publications `I : A Freeform Mathematics Text \<close>
text*[csp_paper_synthesis::technical, main_author = "Some bu"]\<open>We present a typical mathematical
paper focussing on its form, not refering in any sense to its content which is out of scope here.
As mentioned before, we chose the paper~@{cite "taha.ea:philosophers:2020"} for this purpose,
which is written in the so-called free-form style: Formulas are superficially parsed and 
type-setted, but no deeper type-checking and checking with the underlying logical context
is undertaken.

The corpus of the beginning looks like this (the setup seaquence is described later):\<close>
(* . Focus: Mathematical content. Definition, theorem, and citations... *)
figure*[fig0::figure,spawn_columns=False,relative_width="95",src="''figures/header_CSP_source.png''"]
       \<open> A mathematics paper as a document source ... \<close>  
text\<open>The document build process converts this to the following \<^pdf>-output:\<close>

figure*[fig0B::figure,spawn_columns=False,relative_width="95",src="''figures/header_CSP_pdf.png''"]
       \<open> \ldots and as its resulting \<^pdf>-output. \<close>  

text\<open>Recall that the standard syntax for a text-element in \<^isadof> is 
\<^theory_text>\<open>text*[<id>::<class_id>,<attrs>]\<open> ... text ...\<close>\<close>, but there are a few built-in abbreviations like
\<^theory_text>\<open>title*[<id>,<attrs>]\<open> ... text ...\<close>\<close> that provide special command-level syntax for text-elements. 
The other text-elements provide the authors and the abstract as specified by their class-id referring
to the \<^theory_text>\<open>doc_class\<close>es of \<^verbatim>\<open>scholarly_paper\<close>; we say that these text elements are \<^emph>\<open>instances\<close> 
\<^bindex>\<open>instance\<close> of the \<^theory_text>\<open>doc_class\<close>es \<^bindex>\<open>doc\_class\<close> of the underlying ontology. \<close>

text\<open>The paper proceeds by providing instances for introduction, technical sections, examples, \<^etc>.
We would like to concentrate on one --- mathematical paper oriented --- detail in the ontology 
\<^verbatim>\<open>scholarly_paper\<close>: 
@{theory_text [display]
\<open>doc_class technical = text_section +
   . . .

type_synonym tc = technical (* technical content *)

datatype math_content_class = "defn"   | "axm"  | "thm"  | "lem" | "cor" | "prop" | ...
                           
doc_class math_content = tc +
   ...

doc_class "definition"  = math_content +
   mcc           :: "math_content_class" <= "defn" 
   ...

doc_class "theorem"     = math_content +
   mcc           :: "math_content_class" <= "thm" 
   ... 
\<close>}\<close>

text\<open>The class \<^verbatim>\<open>technical\<close> regroups a number of text-elements that contain typical 
"technical content" in mathematical or engineering papers: code, definitions, theorems, 
lemmas, examples. From this class, the more stricter class of @{typ \<open>math_content\<close>} is derived,
which is grouped into @{typ "definition"}s and @{typ "theorem"}s (the details of these
class definitions are omitted here). Note, however, that class identifiers can be abbreviated by 
standard \<^theory_text>\<open>type_synonym\<close>s for convenience and enumeration types can be defined by the 
standard inductive \<^theory_text>\<open>datatype\<close> definition mechanism in Isabelle, since any HOL type is admitted
for attibute declarations. Vice-versa, document class definitions imply a corresponding HOL type 
definition. \<close>

(* For Achim zum spielen...
text\<open>For example, this allows the following presentation in the source:
@{boxed_theory_text [display] \<open>
text*[X2::"definition"]\<open>\<open>RUN A \<equiv> \<mu> X. \<box> x \<in> A \<rightarrow> X\<close>                       \<^vs>\<open>-0.7cm\<close>\<close>
text*[X3::"definition"]\<open>\<open>CHAOS A \<equiv> \<mu> X. (STOP \<sqinter> (\<box> x \<in> A \<rightarrow> X))\<close>          \<^vs>\<open>-0.7cm\<close>\<close>
text*[X4::"definition"]\<open>\<open>CHAOS\<^sub>S\<^sub>K\<^sub>I\<^sub>P A \<equiv> \<mu> X. (SKIP \<sqinter> STOP \<sqinter> (\<box> x \<in> A \<rightarrow> X))\<close>\<^vs>\<open>-0.7cm\<close>\<close>

text\<open> The \<open>RUN\<close>-process defined @{definition X2} represents the process that accepts all 
events, but never stops nor deadlocks. The \<open>CHAOS\<close>-process comes in two variants shown in 
@{definition X3} and @{definition X4}: the process that non-deterministically stops or 
accepts any offered event, wheras \<open>CHAOS\<^sub>S\<^sub>K\<^sub>I\<^sub>P\<close> can additionaly terminate.\<close>
\<close>}
\<close>
*)

(* alternative *)
text\<open>For example, this allows the following presentation in the integrated source:\<close>
figure*[fig01::figure,spawn_columns=False,relative_width="95",src="''figures/definition-use-CSP.png''"]
       \<open> A screenshot of the integrated source with Definitions ...\<close>  
text\<open>which declares a \<^theory_text>\<open>definition\<close> according to the \<^verbatim>\<open>scholarly_paper\<close>-ontology and uses it 
subsequently. Note that the use in the ontology-generated antiquotation \<^theory_text>\<open>@{definition X2}\<close>
is type-checked; referencing \<^verbatim>\<open>X2\<close> as \<^theory_text>\<open>theorem\<close> would be a type-error and be reported directly
by \<^isadof>. Note further, that if referenced correctly wrt. to the sub-typing hierarchy makes
\<^verbatim>\<open>X2\<close> \<^emph>\<open>navigable\<close> in Isabelle/jedit.

The correspondiong output looks as follows:\<close>

figure*[fig02::figure,spawn_columns=False,relative_width="95",src="''figures/definition-use-CSP-pdf.png''"]
       \<open> ... and the corresponding pdf-oputput.\<close>  

text\<open>PROBLEM : SHOULD BE Definition 2 and NOT JUST A LINK ...\<close>


subsection\<open>Writing Academic Publications II (somewhat outdated)\<close>
text\<open> In our next example we concentrate on non-text-elements. Focus on Figures...

\<close>

figure*[fig1::figure,spawn_columns=False,relative_width="95",src="''figures/Dogfood-Intro''"]
       \<open> Ouroboros I: This paper from inside \ldots \<close>  

text\<open> 
  @{docitem \<open>fig1\<close>} shows the corresponding view in the Isabelle/jedit of the start of an academic 
  paper. The text uses \<^isadof>'s own text-commands containing the meta-information provided by the 
  underlying ontology. We proceed by a definition of \<^boxed_theory_text>\<open>introduction\<close>'s, which we define 
  as the extension of \<^boxed_theory_text>\<open>text_section\<close> which is intended to capture common infrastructure:

@{boxed_theory_text [display]\<open>
doc_class introduction = text_section +
   comment :: string
\<close>}

  As a consequence of the definition as extension, the \<^boxed_theory_text>\<open>introduction\<close> class
  inherits the attributes \<^boxed_theory_text>\<open>main_author\<close> and \<^boxed_theory_text>\<open>todo_list\<close> 
  together with the corresponding default values.

  We proceed more or less conventionally by the subsequent sections:

@{boxed_theory_text [display]\<open>
doc_class technical = text_section +
   definition_list :: "string list" <=  "[]"

doc_class example   = text_section +
   comment :: string

doc_class conclusion = text_section +
   main_author :: "author option"  <=  None
   
doc_class related_work = conclusion +
   main_author :: "author option"  <=  None

\<close>}

Moreover, we model a document class for including figures (actually, this document class is already 
defined in the core ontology of \<^isadof>):

@{boxed_theory_text [display]\<open>
datatype placement = h | t | b | ht | hb   
doc_class figure   = text_section +
   relative_width  :: "int" (* percent of textwidth *)    
   src             :: "string"
   placement       :: placement 
   spawn_columns   :: bool <= True 
\<close>}
\<close>
figure*[fig_figures::figure,spawn_columns=False,relative_width="85",src="''figures/Dogfood-figures''"]
       \<open> Ouroboros II: figures \ldots \<close>

text\<open> 
  The document class \<^boxed_theory_text>\<open>figure\<close> (supported by the \<^isadof> command 
  \<^boxed_theory_text>\<open>figure*\<close>) makes it possible to express the pictures and diagrams 
  such as @{docitem \<open>fig_figures\<close>}.

  Finally, we define a monitor class definition that enforces a textual ordering
  in the document core by a regular expression:

@{boxed_theory_text [display]\<open>
doc_class article = 
   style_id :: string                <= "''LNCS''"
   version  :: "(int \<times> int \<times> int)"  <= "(0,0,0)"
   where "(title       ~~ \<lbrakk>subtitle\<rbrakk>   ~~ \<lbrace>author\<rbrace>$^+$+  ~~  abstract    ~~
             introduction ~~  \<lbrace>technical || example\<rbrace>$^+$  ~~  conclusion ~~  
             bibliography)"
\<close>}
\<close>

subsection*[scholar_pide::example]\<open>Editing Support for Academic Papers\<close>
side_by_side_figure*[exploring::side_by_side_figure,anchor="''fig-Dogfood-II-bgnd1''",
                      caption="''Exploring a reference of a text-element.''",relative_width="48",
                      src="''figures/Dogfood-II-bgnd1''",anchor2="''fig-bgnd-text_section''",
                      caption2="''Exploring the class of a text element.''",relative_width2="47",
                      src2="''figures/Dogfood-III-bgnd-text_section''"]\<open>Exploring text elements.\<close>


side_by_side_figure*["hyperlinks"::side_by_side_figure,anchor="''fig:Dogfood-IV-jumpInDocCLass''",
                      caption="''Hyperlink to class-definition.''",relative_width="48",
                      src="''figures/Dogfood-IV-jumpInDocCLass''",anchor2="''fig:Dogfood-V-attribute''",
                      caption2="''Exploring an attribute.''",relative_width2="47",
                      src2="''figures/Dogfood-III-bgnd-text_section''"]\<open> Hyperlinks.\<close>
text\<open> 
  From these class definitions, \<^isadof> also automatically generated editing 
  support for Isabelle/jedit. In \autoref{fig-Dogfood-II-bgnd1} and 
  \autoref{fig-bgnd-text_section} we show how hovering over links permits to explore its 
  meta-information. Clicking on a document class identifier permits to hyperlink into the 
  corresponding class definition (\autoref{fig:Dogfood-IV-jumpInDocCLass}); hovering over an 
  attribute-definition (which is qualified in order to disambiguate; 
  \autoref{fig:Dogfood-V-attribute}).
\<close>
(* Bu : This autoref stuff could be avoided if we would finally have monitors... *)

figure*[figDogfoodVIlinkappl::figure,relative_width="80",src="''figures/Dogfood-V-attribute''"]
       \<open> Exploring an attribute (hyperlinked to the class). \<close> 

text\<open> 
  An ontological reference application in @{figure "figDogfoodVIlinkappl"}: the 
  ontology-dependant antiquotation \<^boxed_theory_text>\<open>@ {example ...}\<close> refers to the corresponding 
  text-elements. Hovering allows for inspection, clicking for jumping to the definition.  If the 
  link does not exist or  has a non-compatible type, the text is not validated.
\<close>

section*[cenelec_onto::example]\<open>Writing Certification Documents (CENELEC\_50128)\<close>
subsection\<open>The CENELEC 50128 Example\<close>
text\<open> 
  The ontology ``CENELEC\_50128''\index{ontology!CENELEC\_50128} is a small ontology modeling 
  documents for a certification following CENELEC 50128~@{cite "boulanger:cenelec-50128:2015"}.
  The \<^isadof> distribution contains a small example  using the ontology ``CENELEC\_50128'' in 
  the directory \nolinkurl{examples/CENELEC_50128/mini_odo/}. You can inspect/edit the example 
  in Isabelle's IDE, by either 
  \<^item> starting Isabelle/jedit using your graphical user interface (\<^eg>, by clicking on the 
    Isabelle-Icon provided by the Isabelle installation) and loading the file 
    \nolinkurl{examples/CENELEC_50128/mini_odo/mini_odo.thy}.
  \<^item> starting Isabelle/jedit from the command line by calling:

    \begin{bash}
ë\prompt{\isadofdirn}ë 
  isabelle jedit examples/CENELEC_50128/mini_odo/mini_odo.thy
\end{bash}
\<close> 
text\<open>  
  You can build the PDF-document by calling:

  \begin{bash}
ë\prompt{}ë isabelle build mini_odo
\end{bash}
\<close>
 
subsection\<open>Modeling CENELEC 50128\<close>
text\<open>
  Documents to be provided in formal certifications (such as CENELEC 
  50128~@{cite "boulanger:cenelec-50128:2015"} or Common Criteria~@{cite "cc:cc-part3:2006"}) can 
  much profit from the control of ontological consistency:  a lot of an evaluators work consists in 
  tracing down the links from requirements over assumptions down to elements of evidence, be it in 
  the models, the code, or the tests.  In a certification process, traceability becomes a major 
  concern; and providing mechanisms to ensure complete traceability already at the development of 
  the global document will clearly increase speed and reduce risk and cost of a certification 
  process. Making the link-structure machine-checkable, be it between requirements, assumptions, 
  their implementation and their discharge by evidence (be it tests, proofs, or authoritative 
  arguments), is therefore natural and has the potential to decrease the cost of developments 
  targeting certifications. Continuously checking the links between the formal and the semi-formal 
  parts of such documents is particularly valuable during the (usually collaborative) development 
  effort. 

  As in many other cases, formal certification documents come with an own terminology and pragmatics
  of what has to be demonstrated and where, and how the trace-ability of requirements through 
  design-models over code to system environment assumptions has to be assured.  

  In the sequel, we present a simplified version of an ontological model used in a 
  case-study~@{cite "bezzecchi.ea:making:2018"}. We start with an introduction of the concept of 
  requirement:

@{boxed_theory_text [display]\<open>
doc_class requirement = long_name :: "string option"

doc_class requirement_analysis = no :: "nat"
   where "requirement_item +"

doc_class hypothesis = requirement +
      hyp_type :: hyp_type <= physical  (* default *)
  
datatype ass_kind = informal | semiformal | formal
  
doc_class assumption = requirement +
     assumption_kind :: ass_kind <= informal 
\<close>}

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
@{boxed_theory_text [display]\<open>  
doc_class ec = assumption  +
     assumption_kind :: ass_kind <= (*default *) formal
                        
doc_class srac = ec  +
     assumption_kind :: ass_kind <= (*default *) formal
\<close>}

We now can, \<^eg>, write 

@{boxed_theory_text [display]\<open>
text*[ass123::SRAC]\<open> 
  The overall sampling frequence of the odometer subsystem is therefore 
  14 khz, which includes sampling, computing a$$nd result communication 
  times \ldots
\<close>
\<close>}

This will be shown in the PDF as follows:
\<close>
text*[ass123::SRAC] \<open> The overall sampling frequence of the odometer
subsystem is therefore 14 khz, which includes sampling, computing and
result communication times \ldots \<close>

subsection*[ontopide::technical]\<open>Editing Support for CENELEC 50128\<close>  
figure*[figfig3::figure,relative_width="95",src="''figures/antiquotations-PIDE''"]
\<open> Standard antiquotations referring to theory elements.\<close>
text\<open> The corresponding view in @{docitem  \<open>figfig3\<close>} shows core part of a document 
conformimg to the CENELEC 50128 ontology. The first sample shows standard Isabelle antiquotations 
@{cite "wenzel:isabelle-isar:2020"} into formal entities of a theory. This way, the informal parts 
of a document get ``formal content'' and become more robust under change.\<close>

figure*[figfig5::figure, relative_width="95", src="''figures/srac-definition''"]
        \<open> Defining a SRAC reference \ldots \<close>
figure*[figfig7::figure, relative_width="95", src="''figures/srac-as-es-application''"]
        \<open> Using a SRAC as EC document reference. \<close>
text\<open> The subsequent sample in @{docitem \<open>figfig5\<close>} shows the definition of an
\<^emph>\<open>safety-related application condition\<close>, a side-condition of a theorem which 
has the consequence that a certain calculation must be executed sufficiently fast on an embedded 
device. This condition can not be established inside the formal theory but has to be 
checked by system integration tests. Now we reference in @{docitem  \<open>figfig7\<close>} this 
safety-related condition; however, this happens in a context where general \<^emph>\<open>exported constraints\<close> 
are listed. \<^isadof>'s checks establish that this is legal in the given ontology. 
\<close>    

(*
section*[math_exam::example]\<open>Writing Exams (math\_exam)\<close> 
subsection\<open>The Math Exam Example\<close>
text\<open> 
  The ontology ``math\_exam''\index{ontology!math\_exam} is an experimental ontology modeling 
  the process of writing exams at higher education institution in the United Kingdom, where exams 
  undergo both an internal and external review process. The \<^isadof> distribution contains a tiny 
  example  using the ontology ``math\_exam'' in the directory 
  \nolinkurl{examples/math_exam/MathExam/}. You can inspect/edit the example 
  in Isabelle's IDE, by either 
  \<^item> starting Isabelle/jedit using your graphical user interface (\<^eg>, by clicking on the 
    Isabelle-Icon provided by the Isabelle installation) and loading the file 
    \nolinkurl{examples/math_exam/MathExam/MathExam.thy}.
  \<^item> starting Isabelle/jedit from the command line by calling:

    \begin{bash}
ë\prompt{\isadofdirn}ë 
  isabelle jedit examples/math_exam/MathExam/MathExam.thy
\end{bash}
\<close> 
text\<open>  
  You can build the PDF-document by calling:

  \begin{bash}
ë\prompt{}ë isabelle build MathExam
\end{bash}
\<close>
 
subsection\<open>Modeling Exams\<close>
text\<open>
  The math-exam scenario is an application with mixed formal and semi-formal content. It addresses 
  applications where the author of the exam is not present  during the exam and the preparation 
  requires a very rigorous process.

  We assume that the content has four different types of addressees, which have a different
  \<^emph>\<open>view\<close> on the integrated document: 
  \<^item> the \<^emph>\<open>setter\<close>, \ie, the author of the exam,
  \<^item> the \<^emph>\<open>checker\<close>, \ie, an internal person that checks 
   the exam for feasibility and non-ambiguity, 
  \<^item> the \<^emph>\<open>external\<close>, \ie, an external person that checks 
    the exam for feasibility and non-ambiguity, and 
  \<^item> the \<^emph>\<open>student\<close>, \ie, the addressee of the exam. 
\<close>
text\<open> 
  The latter quality assurance mechanism is used in many universities,
  where for organizational reasons the execution of an exam takes place in facilities
  where the author of the exam is not expected to be physically present.
  Furthermore, we assume a simple grade system (thus, some calculation is required). We 
  can model this as follows: 

@{boxed_theory_text [display]\<open>
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
doc_class Exam_item =  concerns :: "ContentClass set"  
doc_class Exam_item =  concerns :: "ContentClass set"  

type_synonym SubQuestion = string
\<close>}

  The heart of this ontology is an alternation of questions and answers, where the answers can 
  consist of simple yes-no answers or lists of formulas. Since we do not assume familiarity of 
  the students with Isabelle (\<^boxed_theory_text>\<open>term\<close> would assume that this is a parse-able and 
  type-checkable entity), we basically model a derivation as a sequence of strings:

@{boxed_theory_text [display]\<open>
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
\<close>}

In many institutions, having a rigorous process of validation for exam subjects makes sense: is 
the initial question correct? Is a proof in the sense of the question possible? We model the 
possibility that the @{term examiner} validates a question by a sample proof validated by Isabelle:

@{boxed_theory_text [display]\<open>
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
\<close>}

In our scenario this sample proofs are completely \<^emph>\<open>intern\<close>, \ie, not exposed to the 
students but just additional material for the internal review process of the exam.
\<close>

*)

section\<open>Style Guide\<close>
text\<open>
  The document generation process of \<^isadof> is based on Isabelle's document generation framework, 
  using \<^LaTeX>{} as the underlying back-end. As Isabelle's document generation framework, it is 
  possible to embed (nearly) arbitrary \<^LaTeX>-commands in text-commands, \<^eg>:

@{boxed_theory_text [display]\<open>
text\<open> This is \emph{emphasized} a$$nd this is a 
       citation~\cite{brucker.ea:isabelle-ontologies:2018}\<close>
\<close>}

  In general, we advise against this practice and, whenever positive, use the \<^isadof> (respetively
  Isabelle) provided alternatives:

@{boxed_theory_text [display]\<open>
text\<open> This is *\<open>emphasized\<close> a$$nd this is a 
        citation <@>{cite "brucker.ea:isabelle-ontologies:2018"}.\<close>
\<close>}

Clearly, this is not always possible and, in fact, often \<^isadof> documents will contain 
\<^LaTeX>-commands, this should be restricted to layout improvements that otherwise are (currently)
not possible. As far as possible, the use of \<^LaTeX>-commands should be restricted to the definition 
of ontologies and document templates (see @{docitem (unchecked) \<open>isadof_ontologies\<close>}).

Restricting the use of \<^LaTeX> has two advantages: first, \<^LaTeX> commands can circumvent the 
consistency checks of \<^isadof> and, hence, only if no \<^LaTeX> commands are used, \<^isadof> can 
ensure that a document that does not generate any error messages in Isabelle/jedit also generated
a PDF document. Second, future version of \<^isadof> might support different targets for the 
document generation (\<^eg>, HTML) which, naturally, are only available to documents not using 
native \<^LaTeX>-commands. 

Similarly, (unchecked) forward references should, if possible, be avoided, as they also might
create dangeling references during the document generation that break the document generation.  

Finally, we recommend to use the @{command "check_doc_global"} command at the end of your 
document to check the global reference structure. 

\<close>

(*<*)
end
(*>*) 
  
