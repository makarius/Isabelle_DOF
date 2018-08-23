chapter \<open>A More Or Less Structured File with my Personal, Ecclectic Comments 
          on Internal Isabelle/Infrastructure \<close>

text" Covering Parsers, Pretty-Printers and Presentation, and Kernel. "
  
theory MyCommentedIsabelle
  imports Main
  
begin
  
section "Isabelle/Pure bootstrap";
  text "The Fundamental Boot Order gives an Idea on Module Dependencies: "
  text \<open> @{file "$ISABELLE_HOME/src/Pure/ROOT.ML"}\<close>
    
  text "It's even roughly commented ... "
  (* Paradigmatic Example for Antiquotation programming *)  
  text \<open> @{footnote \<open>sdf\<close>  }\<close>    
  
section{* Stuff - Interesting operators (just sample code) *}    

(* General combinators (in Pure/General/basics.ML)*)
ML{*
(*
    exception Bind
    exception Chr
    exception Div
    exception Domain
    exception Fail of string
    exception Match
    exception Overflow
    exception Size
    exception Span
    exception Subscript
 *)
exnName : exn -> string ; (* -- very interisting to query an unknown exception  *)
exnMessage : exn -> string ;
op ! : 'a Unsynchronized.ref -> 'a;
op := : ('a Unsynchronized.ref * 'a) -> unit;

op #> :  ('a -> 'b) * ('b -> 'c) -> 'a -> 'c; (* reversed function composition *)
op o : (('b -> 'c) * ('a -> 'b)) -> 'a -> 'c;
op |-- : ('a -> 'b * 'c) * ('c -> 'd * 'e) -> 'a -> 'd * 'e;
op --| : ('a -> 'b * 'c) * ('c -> 'd * 'e) -> 'a -> 'b * 'e;
op -- : ('a -> 'b * 'c) * ('c -> 'd * 'e) -> 'a -> ('b * 'd) * 'e;
op ? : bool * ('a -> 'a) -> 'a -> 'a;
ignore: 'a -> unit;
op before : ('a * unit) -> 'a;
I: 'a -> 'a;
K: 'a -> 'b -> 'a
*}  

section {*  The Nano-Kernel: Contexts,  (Theory)-Contexts, (Proof)-Contexts *}

text\<open> What I call the 'Nano-Kernel' in Isabelle can also be seen as an acyclic theory graph.
The meat of it can be found in the file @{file "$ISABELLE_HOME/src/Pure/context.ML"}. 
My notion is a bit criticisable since this entity, which provides the type of theory
and proof_context which is not that Nano after all.
However, these type are pretty empty place-holders at that level and the content of
@{file  "$ISABELLE_HOME/src/Pure/theory.ML"} is registered much later.
The sources themselves mention it as "Fundamental Structure"
and in principle theories and proof contexts could be REGISTERED as user data;
the chosen specialization is therefore an acceptable meddling of the abstraction "Nano-Kernel"
and its application context: Isabelle.

Makarius himself says about this structure:

"Generic theory contexts with unique identity, arbitrarily typed data,
monotonic development graph and history support.  Generic proof
contexts with arbitrarily typed data."

A context is essentially a container with
\<^item> an id
\<^item> a list of parents (so: the graph structure)
\<^item> a time stamp and
\<^item> a sub-context relation (which uses a combination of the id and the time-stamp to
  establish this relation very fast whenever needed; it plays a crucial role for the
  context transfer in the kernel.


A context comes in form of three 'flavours':
\<^item> theories
\<^item> Proof-Contexts (containing theories but also additional information if Isar goes into prove-mode)
\<^item> Generic (the sum of both)

All context have to be seen as mutable; so there are usually transformations defined on them
which are possible as long as a particular protocol (begin_thy - end_thy etc) are respected.

Contexts come with type user-defined data which is mutable through the entire lifetime of
a context.
\<close>  

subsection\<open> Mechanism 1 : Core Interface. \<close>

  
ML{*
Context.parents_of: theory -> theory list;
Context.ancestors_of: theory -> theory list;
Context.proper_subthy : theory * theory -> bool;
Context.Proof: Proof.context -> Context.generic; (*constructor*)
Context.proof_of : Context.generic -> Proof.context;
Context.certificate_theory_id : Context.certificate -> Context.theory_id;
Context.theory_name : theory -> string;
Context.map_theory: (theory -> theory) -> Context.generic -> Context.generic;
(* Theory.map_thy; *)

open Context; (* etc *)
*}
  


subsection\<open>Mechanism 2 : global arbitrary data structure that is attached to the global and
   local Isabelle context $\theta$ \<close>
ML {*

datatype X = mt
val init = mt;
val ext = I
fun merge (X,Y) = mt

structure Data = Generic_Data
(
  type T = X
  val empty  = init
  val extend = ext
  val merge  = merge
);  

*}



ML{*
(*
signature CONTEXT =
sig
  include BASIC_CONTEXT
  (*theory context*)
  type theory_id
  val theory_id: theory -> theory_id
  val timing: bool Unsynchronized.ref
  val parents_of: theory -> theory list
  val ancestors_of: theory -> theory list
  val theory_id_name: theory_id -> string
  val theory_name: theory -> string
  val PureN: string
...
end
*)
*}

section\<open>  Kernel: terms, types, theories, proof_contexts, thms \<close>  

subsection{* Terms and Types *}
text \<open>A basic data-structure of the kernel is term.ML \<close>  
ML{* open Term;
(*
  type indexname = string * int
  type class = string
  type sort = class list
  type arity = string * sort list * sort
  datatype typ =
    Type  of string * typ list |
    TFree of string * sort |
    TVar  of indexname * sort
  datatype term =
    Const of string * typ |
    Free of string * typ |
    Var of indexname * typ |
    Bound of int |
    Abs of string * typ * term |
    $ of term * term
  exception TYPE of string * typ list * term list
  exception TERM of string * term list
*)
*}
  
ML{* Type.typ_instance: Type.tsig -> typ * typ -> bool (* raises  TYPE_MATCH *) *}
text{* there is a joker type that can be added as place-holder during term construction.
       Jokers can be eliminated by the type inference. *}
  
ML{*  Term.dummyT : typ *}
  
subsection{* Type-Certification (=checking that a type annotation is consistent) *}

ML{*
Sign.typ_instance: theory -> typ * typ -> bool;
Sign.typ_match: theory -> typ * typ -> Type.tyenv -> Type.tyenv;
Sign.typ_unify: theory -> typ * typ -> Type.tyenv * int -> Type.tyenv * int;
Sign.const_type: theory -> string -> typ option;
Sign.certify_term: theory -> term -> term * typ * int;   (* core routine for CERTIFICATION of types*)
Sign.cert_term: theory -> term -> term;                  (* short-cut for the latter *)
Sign.tsig_of: theory -> Type.tsig                        (* projects the type signature *)
*}
text{* 
@{ML "Sign.typ_match"} etc. is actually an abstract wrapper on the structure 
@{ML_structure "Type"} 
which contains the heart of the type inference. 
It also contains the type substitution type  @{ML_type "Type.tyenv"} which is
is actually a type synonym for @{ML_type "(sort * typ) Vartab.table"} 
which in itself is a synonym for @{ML_type "'a Symtab.table"}, so 
possesses the usual @{ML "Symtab.empty"} and  @{ML "Symtab.dest"} operations. *}  

text\<open>Note that @{emph \<open>polymorphic variables\<close>} are treated like constant symbols 
in the type inference; thus, the following test, that one type is an instance of the
other, yields false:
\<close>
ML\<open>
val ty = @{typ "'a option"};
val ty' = @{typ "int option"};

val Type("List.list",[S]) = @{typ "('a) list"}; (* decomposition example *)

val false = Sign.typ_instance @{theory}(ty', ty);
\<close>
text\<open>In order to make the type inference work, one has to consider @{emph \<open>schematic\<close>} 
type variables, which are more and more hidden from the Isar interface. Consequently,
the typ antiquotation above will not work for schematic type variables and we have
to construct them by hand on the SML level: \<close>
ML\<open> 
val t_schematic = Type("List.list",[TVar(("'a",0),@{sort "HOL.type"})]);
\<close>
text\<open> MIND THE "'" !!!\<close>
text \<open>On this basis, the following @{ML_type "Type.tyenv"} is constructed: \<close>
ML\<open>
val tyenv = Sign.typ_match ( @{theory}) 
               (t_schematic, @{typ "int list"})
               (Vartab.empty);            
val  [(("'a", 0), (["HOL.type"], @{typ "int"}))] = Vartab.dest tyenv;
\<close>

text{* Type generalization --- the conversion between free type variables and schematic 
type variables ---  is apparently no longer part of the standard API (there is a slightly 
more general replacement in @{ML "Term_Subst.generalizeT_same"}, however). Here is a way to
overcome this by a self-baked generalization function:*}  

ML\<open>
val generalize_typ = Term.map_type_tfree (fn (str,sort)=> Term.TVar((str,0),sort));
val generalize_term = Term.map_types generalize_typ;
val true = Sign.typ_instance @{theory} (ty', generalize_typ ty)
\<close>
text\<open>... or more general variants thereof that are parameterized by the indexes for schematic
type variables instead of assuming just @{ML "0"}. \<close>

text\<open> Example:\<close>
ML\<open>val t = generalize_term @{term "[]"}\<close>

text
\<open>Now we turn to the crucial issue of type-instantiation and with a given type environment
@{ML "tyenv"}. For this purpose, one has to switch to the low-level interface 
@{ML_structure "Term_Subst"}. 
\<close>

ML\<open>
Term_Subst.map_types_same : (typ -> typ) -> term -> term;
Term_Subst.map_aterms_same : (term -> term) -> term -> term;
Term_Subst.instantiate: ((indexname * sort) * typ) list * ((indexname * typ) * term) list -> term -> term;
Term_Subst.instantiateT: ((indexname * sort) * typ) list -> typ -> typ;
Term_Subst.generalizeT: string list -> int -> typ -> typ;
                        (* this is the standard type generalisation function !!!
                           only type-frees in the string-list were taken into account. *)
Term_Subst.generalize: string list * string list -> int -> term -> term
                        (* this is the standard term generalisation function !!!
                           only type-frees and frees in the string-lists were taken 
                           into account. *)
\<close>

text \<open>Apparently, a bizarre conversion between the old-style interface and 
the new-style @{ML "tyenv"} is necessary. See the following example.\<close>
ML\<open>
val S = Vartab.dest tyenv;
val S' = (map (fn (s,(t,u)) => ((s,t),u)) S) : ((indexname * sort) * typ) list;
         (* it took me quite some time to find out that these two type representations,
            obscured by a number of type-synonyms, where actually identical. *)
val ty = t_schematic;
val ty' = Term_Subst.instantiateT S' t_schematic;
val t = (generalize_term @{term "[]"});

val t' = Term_Subst.map_types_same (Term_Subst.instantiateT S') (t)
(* or alternatively : *)
val t'' = Term.map_types (Term_Subst.instantiateT S') (t)
\<close>

subsection{* Type-Inference (= inferring consistent type information if possible) *}

text{* Type inference eliminates also joker-types such as @{ML dummyT} and produces
       instances for schematic type variables where necessary. In the case of success,
       it produces a certifiable term. *}  
ML{*  
Type_Infer_Context.infer_types: Proof.context -> term list -> term list  
*}
  
subsection{* thy and the signature interface*}  
ML\<open>
Sign.tsig_of: theory -> Type.tsig;
Sign.syn_of : theory -> Syntax.syntax;
Sign.of_sort : theory -> typ * sort -> bool ;
\<close>

subsection{* Theories *}


text \<open> This structure yields the datatype \verb*thy* which becomes the content of 
\verb*Context.theory*. In a way, the LCF-Kernel registers itself into the Nano-Kernel,
which inspired me (bu) to this naming. \<close>
ML{*

(* intern Theory.Thy; (* Data-Type Abstraction still makes it an LCF Kernel *)

datatype thy = Thy of
 {pos: Position.T,
  id: serial,
  axioms: term Name_Space.table,
  defs: Defs.T,
  wrappers: wrapper list * wrapper list};

*)

Theory.check: Proof.context -> string * Position.T -> theory;

Theory.local_setup: (Proof.context -> Proof.context) -> unit;
Theory.setup: (theory -> theory) -> unit;  (* The thing to extend the table of "command"s with parser - callbacks. *)
Theory.get_markup: theory -> Markup.T;
Theory.axiom_table: theory -> term Name_Space.table;
Theory.axiom_space: theory -> Name_Space.T;
Theory.axioms_of: theory -> (string * term) list;
Theory.all_axioms_of: theory -> (string * term) list;
Theory.defs_of: theory -> Defs.T;
Theory.at_begin: (theory -> theory option) -> theory -> theory;
Theory.at_end: (theory -> theory option) -> theory -> theory;
Theory.begin_theory: string * Position.T -> theory list -> theory;
Theory.end_theory: theory -> theory;

*}

text{* Even the parsers and type checkers stemming from the theory-structure are registered via
hooks (this can be confusing at times). Main phases of inner syntax processing, with standard 
implementations of parse/unparse operations were treated this way.
At the very very end in syntax_phases.ML, it sets up the entire syntax engine 
(the hooks) via:
*}

(* 
val _ =
  Theory.setup
   (Syntax.install_operations
     {parse_sort = parse_sort,
      parse_typ = parse_typ,
      parse_term = parse_term false,
      parse_prop = parse_term true,
      unparse_sort = unparse_sort,
      unparse_typ = unparse_typ,
      unparse_term = unparse_term,
      check_typs = check_typs,
      check_terms = check_terms,
      check_props = check_props,
      uncheck_typs = uncheck_typs,
      uncheck_terms = uncheck_terms});
*)
  
text{*
Thus, Syntax_Phases does the actual work, including markup generation and 
generation of reports. 

Look at: *}
(*
fun check_typs ctxt raw_tys =
  let
    val (sorting_report, tys) = Proof_Context.prepare_sortsT ctxt raw_tys;
    val _ = if Context_Position.is_visible ctxt then Output.report sorting_report else ();
  in
    tys
    |> apply_typ_check ctxt
    |> Term_Sharing.typs (Proof_Context.theory_of ctxt)
  end;

which is the real implementation behind Syntax.check_typ

or:

fun check_terms ctxt raw_ts =
  let
    val (sorting_report, raw_ts') = Proof_Context.prepare_sorts ctxt raw_ts;
    val (ts, ps) = Type_Infer_Context.prepare_positions ctxt raw_ts';

    val tys = map (Logic.mk_type o snd) ps;
    val (ts', tys') = ts @ tys
      |> apply_term_check ctxt
      |> chop (length ts);
    val typing_report =
      fold2 (fn (pos, _) => fn ty =>
        if Position.is_reported pos then
          cons (Position.reported_text pos Markup.typing
            (Syntax.string_of_typ ctxt (Logic.dest_type ty)))
        else I) ps tys' [];

    val _ =
      if Context_Position.is_visible ctxt then Output.report (sorting_report @ typing_report)
      else ();
  in Term_Sharing.terms (Proof_Context.theory_of ctxt) ts' end;

which is the real implementation behind Syntax.check_term

As one can see, check-routines internally generate the markup.

*)  
  
section\<open> Front End \<close>  

subsection{* Parsing issues *}  
  
text\<open> Parsing combinators represent the ground building blocks of both generic input engines
as well as the specific Isar framework. They are implemented in the  structure \verb*Token* 
providing core type \verb+Token.T+. 
\<close>
ML{* open Token*}  

ML{*

(* Provided types : *)
(*
  type 'a parser = T list -> 'a * T list
  type 'a context_parser = Context.generic * T list -> 'a * (Context.generic * T list)
*)

(* conversion between these two : *)

fun parser2contextparser pars (ctxt, toks) = let val (a, toks') = pars toks
                                             in  (a,(ctxt, toks')) end;
val _ = parser2contextparser : 'a parser -> 'a context_parser;

(* bah, is the same as Scan.lift *)
val _ = Scan.lift Args.cartouche_input : Input.source context_parser;

Token.is_command;
Token.content_of; (* textueller kern eines Tokens. *)

*}

text{* Tokens and Bindings *}  


ML{*
val H = @{binding here}; (* There are "bindings" consisting of a text-span and a position, 
                    where \<dieresis>positions\<dieresis> are absolute references to a file *)                                  

Binding.make: bstring * Position.T -> binding;
Binding.pos_of @{binding erzerzer};
Position.here: Position.T -> string;
(* Bindings *)
ML\<open>val X = @{here};\<close>  

*}  

subsection {*Input streams. *}  
ML{*  
  Input.source_explode : Input.source -> Symbol_Pos.T list;
     (* conclusion: Input.source_explode converts " f @{thm refl}" 
        into: 
        [(" ", {offset=14, id=-2769}), ("f", {offset=15, id=-2769}), (" ", {offset=16, id=-2769}),
        ("@", {offset=17, id=-2769}), ("{", {offset=18, id=-2769}), ("t", {offset=19, id=-2769}),
        ("h", {offset=20, id=-2769}), ("m", {offset=21, id=-2769}), (" ", {offset=22, id=-2769}),
        ("r", {offset=23, id=-2769}), ("e", {offset=24, id=-2769}), ("f", {offset=25, id=-2769}),
        ("l", {offset=26, id=-2769}), ("}", {offset=27, id=-2769})]
     *)*} 
  
subsection {*Scanning and combinator parsing. *}  
ML\<open>
Scan.peek  : ('a -> 'b -> 'c * 'd) -> 'a * 'b -> 'c * ('a * 'd);
Scan.optional: ('a -> 'b * 'a) -> 'b -> 'a -> 'b * 'a;
Scan.option: ('a -> 'b * 'a) -> 'a -> 'b option * 'a;
Scan.repeat: ('a -> 'b * 'a) -> 'a -> 'b list * 'a;
Scan.lift  : ('a -> 'b * 'c) -> 'd * 'a -> 'b * ('d * 'c);
Scan.lift (Parse.position Args.cartouche_input);
\<close>
  
text{* "parsers" are actually  interpreters; an 'a parser is a function that parses
   an input stream and computes(=evaluates, computes) it into 'a. 
   Since the semantics of an Isabelle command is a transition => transition 
   or theory \<Rightarrow> theory  function, i.e. a global system transition.
   parsers of that type can be constructed and be bound as call-back functions
   to a table in the Toplevel-structure of Isar.

   The type 'a parser is already defined in the structure Token.
*}
  
text{* Syntax operations : Interface for parsing, type-checking, "reading" 
                       (both) and pretty-printing.
   Note that this is a late-binding interface, i.e. a collection of "hooks".
   The real work is done ... see below. 
   
   Encapsulates the data structure "syntax" --- the table with const symbols, 
   print and ast translations, ... The latter is accessible, e.g. from a Proof
   context via Proof_Context.syn_of.
*}
  
ML\<open>
Parse.nat: int parser;  
Parse.int: int parser;
Parse.enum_positions: string -> 'a parser -> ('a list * Position.T list) parser;
Parse.enum: string -> 'a parser -> 'a list parser;
Parse.input: 'a parser -> Input.source parser;

Parse.enum : string -> 'a parser -> 'a list parser;
Parse.!!! : (T list -> 'a) -> T list -> 'a;
Parse.position: 'a parser -> ('a * Position.T) parser;

(* Examples *)                                     
Parse.position Args.cartouche_input;
\<close>

text{* Parsing combinators for elementary Isabelle Lexems*}  
ML{* 
Syntax.parse_sort;
Syntax.parse_typ;
Syntax.parse_term;
Syntax.parse_prop;
Syntax.check_term;
Syntax.check_props;
Syntax.uncheck_sort;
Syntax.uncheck_typs;
Syntax.uncheck_terms;
Syntax.read_sort;
Syntax.read_typ;
Syntax.read_term;
Syntax.read_typs;
Syntax.read_sort_global;
Syntax.read_typ_global;
Syntax.read_term_global;
Syntax.read_prop_global;
Syntax.pretty_term;
Syntax.pretty_typ;
Syntax.pretty_sort;
Syntax.pretty_classrel;
Syntax.pretty_arity;
Syntax.string_of_term;
Syntax.string_of_typ;
Syntax.lookup_const;
*}

ML{*
fun read_terms ctxt =
  grouped 10 Par_List.map_independent (Syntax.parse_term ctxt) #> Syntax.check_terms ctxt;
*}  

ML\<open>
(* More High-level, more Isar-specific Parsers *)
Args.name;
Args.const;
Args.cartouche_input: Input.source parser; 
Args.text_token: Token.T parser;

val Z = let val attribute = Parse.position Parse.name -- 
                            Scan.optional (Parse.$$$ "=" |-- Parse.!!! Parse.name) "";
        in (Scan.optional(Parse.$$$ "," |-- (Parse.enum "," attribute))) end ;
(* this leads to constructions like the following, where a parser for a *)
fn name => (Thy_Output.antiquotation name (Scan.lift (Parse.position Args.cartouche_input)));
\<close>

subsection\<open> Markup \<close>  
text{* Markup Operations, and reporting. Diag in Isa_DOF Foundations Paper.
       Markup operation send via side-effect annotations to the GUI (precisely:
       to the PIDE Framework) that were used for hyperlinking applicating to binding
       occurrences, info for hovering, ... *}  
ML{*

(* Position.report is also a type consisting of a pair of a position and markup. *)
(* It would solve all my problems if I find a way to infer the defining Position.report
   from a type definition occurence ... *)

Position.report: Position.T -> Markup.T -> unit;
Position.reports: Position.report list -> unit; 
     (* ? ? ? I think this is the magic thing that sends reports to the GUI. *)
Markup.entity : string -> string -> Markup.T;
Markup.properties : Properties.T -> Markup.T -> Markup.T ;
Properties.get : Properties.T -> string -> string option;
Markup.enclose : Markup.T -> string -> string; 
     
(* example for setting a link, the def flag controls if it is a defining or a binding 
occurence of an item *)
fun theory_markup (def:bool) (name:string) (id:serial) (pos:Position.T) =
  if id = 0 then Markup.empty
  else
    Markup.properties (Position.entity_properties_of def id pos)
      (Markup.entity Markup.theoryN name);
Markup.theoryN : string;

serial();   (* A global, lock-guarded seriel counter used to produce unique identifiers,
               be it on the level of thy-internal states or as reference in markup in
               PIDE *)

(* From Theory:
fun check ctxt (name, pos) =
  let
    val thy = Proof_Context.theory_of ctxt;
    val thy' =
      Context.get_theory thy name
        handle ERROR msg =>
          let
            val completion =
              Completion.make (name, pos)
                (fn completed =>
                  map Context.theory_name (ancestors_of thy)
                  |> filter completed
                  |> sort_strings
                  |> map (fn a => (a, (Markup.theoryN, a))));
            val report = Markup.markup_report (Completion.reported_text completion);
          in error (msg ^ Position.here pos ^ report) end;
    val _ = Context_Position.report ctxt pos (get_markup thy');
  in thy' end;

fun init_markup (name, pos) thy =
  let
    val id = serial ();
    val _ = Position.report pos (theory_markup true name id pos);
  in map_thy (fn (_, _, axioms, defs, wrappers) => (pos, id, axioms, defs, wrappers)) thy end;

fun get_markup thy =
  let val {pos, id, ...} = rep_theory thy
  in theory_markup false (Context.theory_name thy) id pos end;


*)

(*
fun theory_markup def thy_name id pos =
  if id = 0 then Markup.empty
  else
    Markup.properties (Position.entity_properties_of def id pos)
      (Markup.entity Markup.theoryN thy_name);

fun get_markup thy =
  let val {pos, id, ...} = rep_theory thy
  in theory_markup false (Context.theory_name thy) id pos end;


fun init_markup (name, pos) thy =
  let
    val id = serial ();
    val _ = Position.report pos (theory_markup true name id pos);
  in map_thy (fn (_, _, axioms, defs, wrappers) => (pos, id, axioms, defs, wrappers)) thy end;


fun check ctxt (name, pos) =
  let
    val thy = Proof_Context.theory_of ctxt;
    val thy' =
      Context.get_theory thy name
        handle ERROR msg =>
          let
            val completion =
              Completion.make (name, pos)
                (fn completed =>
                  map Context.theory_name (ancestors_of thy)
                  |> filter completed
                  |> sort_strings
                  |> map (fn a => (a, (Markup.theoryN, a))));
            val report = Markup.markup_report (Completion.reported_text completion);
          in error (msg ^ Position.here pos ^ report) end;
    val _ = Context_Position.report ctxt pos (get_markup thy');
  in thy' end;


*)

*}

  
  
subsection {* Output: Very Low Level *}
ML\<open> 
Output.output; (* output is the  structure for the "hooks" with the target devices. *)
Output.output "bla_1:";
\<close>

subsection {* Output: High Level *}
  
ML\<open> 
Thy_Output.verbatim_text;
Thy_Output.output_text: Toplevel.state -> {markdown: bool} -> Input.source -> string;
Thy_Output.antiquotation:
   binding ->
     'a context_parser ->
       ({context: Proof.context, source: Token.src, state: Toplevel.state} -> 'a -> string) ->
         theory -> theory;
Thy_Output.output: Proof.context -> Pretty.T list -> string;
Thy_Output.output_text: Toplevel.state -> {markdown: bool} -> Input.source -> string;

Thy_Output.output : Proof.context -> Pretty.T list -> string;
\<close>



ML{*
Syntax_Phases.reports_of_scope;
*}



(* Pretty.T, pretty-operations. *)  
ML{*

(* interesting piece for LaTeX Generation: 
fun verbatim_text ctxt =
  if Config.get ctxt display then
    split_lines #> map (prefix (Symbol.spaces (Config.get ctxt indent))) #> cat_lines #>
    Latex.output_ascii #> Latex.environment "isabellett"
  else
    split_lines #>
    map (Latex.output_ascii #> enclose "\\isatt{" "}") #>
    space_implode "\\isasep\\isanewline%\n";

(* From structure Thy_Output *)
fun pretty_const ctxt c =
  let
    val t = Const (c, Consts.type_scheme (Proof_Context.consts_of ctxt) c)
      handle TYPE (msg, _, _) => error msg;
    val ([t'], _) = Variable.import_terms true [t] ctxt;
  in pretty_term ctxt t' end;

  basic_entity @{binding const} (Args.const {proper = true, strict = false}) pretty_const #>

*)

Pretty.enclose : string -> string -> Pretty.T list -> Pretty.T; (* not to confuse with: String.enclose *)

(* At times, checks where attached to Pretty - functions and exceptions used to
   stop the execution/validation of a command *)
fun pretty_theory ctxt (name, pos) = (Theory.check ctxt (name, pos); Pretty.str name);
Pretty.enclose;
Pretty.str;
Pretty.mark_str;
Pretty.text "bla_d";

Pretty.quote; (* Pretty.T transformation adding " " *) 
Pretty.unformatted_string_of : Pretty.T -> string ;

Latex.output_ascii;
Latex.environment "isa" "bg";
Latex.output_ascii "a_b:c'é";
(* Note: *)
space_implode "sd &e sf dfg" ["qs","er","alpa"];


(*
fun pretty_command (cmd as (name, Command {comment, ...})) =
  Pretty.block
    (Pretty.marks_str
      ([Active.make_markup Markup.sendbackN {implicit = true, properties = [Markup.padding_line]},
        command_markup false cmd], name) :: Pretty.str ":" :: Pretty.brk 2 :: Pretty.text comment);
*)


*}  

  

  
ML{* 
Toplevel.theory; 
Toplevel.presentation_context_of; (* Toplevel is a kind of table with call-bacl functions *)

Consts.the_const; (* T is a kind of signature ... *)
Variable.import_terms;
Vartab.update;

fun control_antiquotation name s1 s2 =
  Thy_Output.antiquotation name (Scan.lift Args.cartouche_input)
    (fn {state, ...} => enclose s1 s2 o Thy_Output.output_text state {markdown = false});

Output.output;

Syntax.read_input ;
Input.source_content;

(*
  basic_entity @{binding const} (Args.const {proper = true, strict = false}) pretty_const #>
*)
*}
  
ML{*
Config.get @{context} Thy_Output.display;
Config.get @{context} Thy_Output.source;
Config.get @{context} Thy_Output.modes;
Thy_Output.document_command;
(* is:
fun document_command markdown (loc, txt) =
  Toplevel.keep (fn state =>
    (case loc of
      NONE => ignore (output_text state markdown txt)
    | SOME (_, pos) =>
        error ("Illegal target specification -- not a theory context" ^ Position.here pos))) o
  Toplevel.present_local_theory loc (fn state => ignore (output_text state markdown txt));

end;

*)
Thy_Output.output_text;
(* is:
fun output_text state {markdown} source =
  let
    val is_reported =
      (case try Toplevel.context_of state of
        SOME ctxt => Context_Position.is_visible ctxt
      | NONE => true);

    val pos = Input.pos_of source;
    val syms = Input.source_explode source;

    val _ =
      if is_reported then
        Position.report pos (Markup.language_document (Input.is_delimited source))
      else ();

    val output_antiquotes = map (eval_antiquote state) #> implode;

    fun output_line line =
      (if Markdown.line_is_item line then "\\item " else "") ^
        output_antiquotes (Markdown.line_content line);

    fun output_blocks blocks = space_implode "\n\n" (map output_block blocks)
    and output_block (Markdown.Par lines) = cat_lines (map output_line lines)
      | output_block (Markdown.List {kind, body, ...}) =
          Latex.environment (Markdown.print_kind kind) (output_blocks body);
  in
    if Toplevel.is_skipped_proof state then ""
    else if markdown andalso exists (Markdown.is_control o Symbol_Pos.symbol) syms
    then
      let
        val ants = Antiquote.parse pos syms;
        val reports = Antiquote.antiq_reports ants;
        val blocks = Markdown.read_antiquotes ants;
        val _ = if is_reported then Position.reports (reports @ Markdown.reports blocks) else ();
      in output_blocks blocks end
    else
      let
        val ants = Antiquote.parse pos (Symbol_Pos.trim_blanks syms);
        val reports = Antiquote.antiq_reports ants;
        val _ = if is_reported then Position.reports (reports @ Markdown.text_reports ants) else ();
      in output_antiquotes ants end
  end;
*)

*}  
  
  
ML{* 
Outer_Syntax.print_commands @{theory};

Outer_Syntax.command : Outer_Syntax.command_keyword -> string -> 
                           (Toplevel.transition -> Toplevel.transition) parser -> unit;
(* creates an implicit thy_setup with an entry for a call-back function, which happens
   to be a parser that must have as side-effect a Toplevel-transition-transition. 
   Registers "Toplevel.transition -> Toplevel.transition" parsers to the Isar interpreter.
   *)

(*Example: text is :
 
val _ =
  Outer_Syntax.command ("text", @{here}) "formal comment (primary style)"
    (Parse.opt_target -- Parse.document_source >> Thy_Output.document_command {markdown = true});
*)
 
(* not exported: Thy_Output.output_token; Ich glaub, da passierts ... *)
Thy_Output.present_thy;
*}
  
ML{* Thy_Output.document_command {markdown = true} *}  
(* Structures related to LaTeX Generation *)
ML{*  Latex.output_ascii;
      Latex.modes;
      Latex.output_token 
(* Hm, generierter output for
subsection*[Shaft_Encoder_characteristics]{ * Shaft Encoder Characteristics * } :

\begin{isamarkuptext}%
\isa{{\isacharbackslash}label{\isacharbraceleft}general{\isacharunderscore}hyps{\isacharbraceright}}%
\end{isamarkuptext}\isamarkuptrue%
\isacommand{subsection{\isacharasterisk}}\isamarkupfalse%
{\isacharbrackleft}Shaft{\isacharunderscore}Encoder{\isacharunderscore}characteristics{\isacharbrackright}{\isacharverbatimopen}\ Shaft\ Encoder\ Characteristics\ {\isacharverbatimclose}%

Generierter output for: text\<open>\label{sec:Shaft-Encoder-characteristics}\<close>

\begin{isamarkuptext}%
\label{sec:Shaft-Encoder-characteristics}%
\end{isamarkuptext}\isamarkuptrue%


*)


*}  
  
ML{*
Thy_Output.maybe_pretty_source : 
     (Proof.context -> 'a -> Pretty.T) -> Proof.context -> Token.src -> 'a list -> Pretty.T list;

Thy_Output.output: Proof.context -> Pretty.T list -> string;

 (* nuescht besonderes *)

fun document_antiq check_file ctxt (name, pos) =
  let
   (* val dir = master_directory (Proof_Context.theory_of ctxt); *)
   (* val _ = check_path check_file ctxt dir (name, pos); *)
  in
    space_explode "/" name
    |> map Latex.output_ascii
    |> space_implode (Latex.output_ascii "/" ^ "\\discretionary{}{}{}")
    |> enclose "\\isatt{" "}"
  end;

*}
ML{* Type_Infer_Context.infer_types *}
ML{* Type_Infer_Context.prepare_positions *}

  
  
section {*Transaction Management in the Isar-Engine : The Toplevel *}
  
ML{*
Thy_Output.output_text: Toplevel.state -> {markdown: bool} -> Input.source -> string;
Thy_Output.document_command;

Toplevel.exit: Toplevel.transition -> Toplevel.transition;
Toplevel.keep: (Toplevel.state -> unit) -> Toplevel.transition -> Toplevel.transition;
Toplevel.keep': (bool -> Toplevel.state -> unit) -> Toplevel.transition -> Toplevel.transition;
Toplevel.ignored: Position.T -> Toplevel.transition;
Toplevel.generic_theory: (generic_theory -> generic_theory) -> Toplevel.transition -> Toplevel.transition;
Toplevel.theory': (bool -> theory -> theory) -> Toplevel.transition -> Toplevel.transition;
Toplevel.theory: (theory -> theory) -> Toplevel.transition -> Toplevel.transition;

Toplevel.present_local_theory:
(xstring * Position.T) option ->
     (Toplevel.state -> unit) -> Toplevel.transition -> Toplevel.transition;
(* where text treatment and antiquotation parsing happens *)


(*fun document_command markdown (loc, txt) =
  Toplevel.keep (fn state =>
    (case loc of
      NONE => ignore (output_text state markdown txt)
    | SOME (_, pos) =>
        error ("Illegal target specification -- not a theory context" ^ Position.here pos))) o
  Toplevel.present_local_theory loc (fn state => ignore (output_text state markdown txt)); *)
Thy_Output.document_command :  {markdown: bool} -> (xstring * Position.T) option * Input.source -> 
                               Toplevel.transition -> Toplevel.transition;

(* Isar Toplevel Steuerung *)
Toplevel.keep :  (Toplevel.state -> unit) -> Toplevel.transition -> Toplevel.transition;
    (* val keep' = add_trans o Keep;
       fun keep f = add_trans (Keep (fn _ => f));
     *)

Toplevel.present_local_theory : (xstring * Position.T) option -> (Toplevel.state -> unit) ->
    Toplevel.transition -> Toplevel.transition;
    (* fun present_local_theory target = present_transaction (fn int =>
           (fn Theory (gthy, _) =>
                   let val (finish, lthy) = Named_Target.switch target gthy;
                   in Theory (finish lthy, SOME lthy) end
           | _ => raise UNDEF));

       fun present_transaction f g = add_trans (Transaction (f, g));
       fun transaction f = present_transaction f (K ());
    *)

Toplevel.theory : (theory -> theory) -> Toplevel.transition -> Toplevel.transition; 
   (* fun theory' f = transaction (fn int =>
                (fn Theory (Context.Theory thy, _) =>
                      let val thy' = thy
                                     |> Sign.new_group
                                     |> f int
                                     |> Sign.reset_group;
                      in Theory (Context.Theory thy', NONE) end
                | _ => raise UNDEF));

      fun theory f = theory' (K f); *)

Thy_Output.document_command : {markdown: bool} -> (xstring * Position.T) option * Input.source ->
    Toplevel.transition -> Toplevel.transition;
    (*  fun document_command markdown (loc, txt) =
            Toplevel.keep (fn state =>
               (case loc of
                   NONE => ignore (output_text state markdown txt)
                         | SOME (_, pos) =>
                   error ("Illegal target specification -- not a theory context" ^ Position.here pos))) o
             Toplevel.present_local_theory loc (fn state => ignore (output_text state markdown txt));

    *)

Thy_Output.output_text : Toplevel.state -> {markdown: bool} -> Input.source -> string ; 
                         (* this is where antiquotation expansion happens : uses eval_antiquote *)


*}  
  
  
ML{*


(* Isar Toplevel Steuerung *)
Toplevel.keep :  (Toplevel.state -> unit) -> Toplevel.transition -> Toplevel.transition;
    (* val keep' = add_trans o Keep;
       fun keep f = add_trans (Keep (fn _ => f));
     *)

Toplevel.present_local_theory : (xstring * Position.T) option -> (Toplevel.state -> unit) ->
    Toplevel.transition -> Toplevel.transition;
    (* fun present_local_theory target = present_transaction (fn int =>
           (fn Theory (gthy, _) =>
                   let val (finish, lthy) = Named_Target.switch target gthy;
                   in Theory (finish lthy, SOME lthy) end
           | _ => raise UNDEF));

       fun present_transaction f g = add_trans (Transaction (f, g));
       fun transaction f = present_transaction f (K ());
    *)

Toplevel.theory : (theory -> theory) -> Toplevel.transition -> Toplevel.transition; 
   (* fun theory' f = transaction (fn int =>
                (fn Theory (Context.Theory thy, _) =>
                      let val thy' = thy
                                     |> Sign.new_group
                                     |> f int
                                     |> Sign.reset_group;
                      in Theory (Context.Theory thy', NONE) end
                | _ => raise UNDEF));

      fun theory f = theory' (K f); *)

Thy_Output.document_command : {markdown: bool} -> (xstring * Position.T) option * Input.source ->
    Toplevel.transition -> Toplevel.transition;
    (*  fun document_command markdown (loc, txt) =
            Toplevel.keep (fn state =>
               (case loc of
                   NONE => ignore (output_text state markdown txt)
                         | SOME (_, pos) =>
                   error ("Illegal target specification -- not a theory context" ^ Position.here pos))) o
             Toplevel.present_local_theory loc (fn state => ignore (output_text state markdown txt));

    *)

Thy_Output.output_text : Toplevel.state -> {markdown: bool} -> Input.source -> string ; 
                         (* this is where antiquotation expansion happens : uses eval_antiquote *)


*}
  
  
subsection\<open> Configuration flags of fixed type in the Isar-engine. \<close>

ML{*
Config.get @{context} Thy_Output.quotes;
Config.get @{context} Thy_Output.display;

val C = Synchronized.var "Pretty.modes" "latEEex"; 
(* Synchronized: a mechanism to bookkeep global
   variables with synchronization mechanism included *)
Synchronized.value C;
(*
fun output ctxt prts =
   603   prts
   604   |> Config.get ctxt quotes ? map Pretty.quote
   605   |> (if Config.get ctxt display then
   606         map (Pretty.indent (Config.get ctxt indent) #> string_of_margin ctxt #> Output.output)
   607         #> space_implode "\\isasep\\isanewline%\n"
   608         #> Latex.environment "isabelle"
   609       else
   610         map
   611           ((if Config.get ctxt break then string_of_margin ctxt else Pretty.unformatted_string_of)
   612             #> Output.output)
   613         #> space_implode "\\isasep\\isanewline%\n"
   614         #> enclose "\\isa{" "}");
*)
*}  
    
  
end