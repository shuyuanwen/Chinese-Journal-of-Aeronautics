%
% Copyright Chinese Society of Aeronautics and Astronautics 2021
%
% This `cja.bst' bibliographic style file (for LaTeX/BibTeX) is
% modified to meet the requirements of Chinese Journal of Aeronautics.
%
% The original file is from:
% https://gitlab.com/fvdbeek/vancouver.bst
% which is based on the Cite Medicine style
% (also known as the Vancouver style)
% The standards are summarized in:
% https://www.nlm.nih.gov/bsd/uniform_requirements.html
% and detailed in:
% https://www.ncbi.nlm.nih.gov/books/NBK7256/
%

ENTRY
  { address
    archiveprefix
    assignee     % for patents
    author
    booktitle    % for articles in books
    chapter      % for incollection, esp. internet documents
    cartographer % for maps
    day
    date
    edition
    editor
    eprinttype
    elocation-id
    eventdate
    eventtitle
    howpublished
    institution  % for technical reports
    inventor     % for patents
    journal
    key
    language
    month
    note
    number
    organization
    pages
    part
    publisher
    school
    series
    title
    type
    venue
    volume
    word
    year
    eprint % urlbst
    doi % urlbst
    url % urlbst
    urldate % urlbst
    lastchecked % urlbst
    updated % urlbst
  }
  {}
  { label extra.label sort.label short.list }
%% Declaration of integer variables
INTEGERS { output.state before.all mid.sentence after.sentence after.block }
STRINGS { urlintro eprinturl eprintprefix doiprefix doiurl } % urlbst...
INTEGERS { hrefform addeprints adddoiresolver }
% Following constants may be adjusted by hand, if desired
FUNCTION {init.config.constants}
{
  "Available from: " 'urlintro := % prefix before URL
  "http://arxiv.org/abs/" 'eprinturl := % prefix to make URL from eprint ref
  "arXiv:" 'eprintprefix := % text prefix printed before eprint ref
  "http://dx.doi.org/" 'doiurl := % prefix to make URL from DOI
  "doi:" 'doiprefix := % text prefix printed before DOI ref
  #0 'addeprints := % 0=no eprints; 1=include eprints
  #0 'adddoiresolver := % 0=no DOI resolver; 1=include it
  #0 'hrefform := % 0=no crossrefs; 1=hypertex xrefs; 2=hyperref refs
}
INTEGERS {
  bracket.state
  outside.brackets
  open.brackets
  within.brackets
  close.brackets
}
% ...urlbst to here
FUNCTION {init.state.consts}
{ #0 'outside.brackets := % urlbst
  #1 'open.brackets :=
  #2 'within.brackets :=
  #3 'close.brackets :=

  #0 'before.all :=
  #1 'mid.sentence :=
  #2 'after.sentence :=
  #3 'after.block :=
}
%% Declaration of string variables
STRINGS { s t}

% urlbst
FUNCTION {output.nonnull.original}
{ 's :=
  output.state mid.sentence =
    { ". " * write$ }
    { output.state after.block =
        { add.period$ write$
          newline$
          "\newblock " write$
        }
        { output.state before.all =
            'write$
            { add.period$ " " * write$ }
          if$
        }
      if$
      mid.sentence 'output.state :=
    }
  if$
  s
}

% urlbst...
FUNCTION {output.nonnull}
{ % Save the thing we've been asked to output
  's :=
  % If the bracket-state is close.brackets, then add a close-bracket to
  % what is currently at the top of the stack, and set bracket.state
  % to outside.brackets
  bracket.state close.brackets =
    { "]" *
      outside.brackets 'bracket.state :=
    }
    'skip$
  if$
  bracket.state outside.brackets =
    { % We're outside all brackets -- this is the normal situation.
      % Write out what's currently at the top of the stack, using the
      % original output.nonnull function.
      s
      output.nonnull.original
    }
    { % Still in brackets.  Add open-bracket or (continuation) comma, add the
      % new text (in s) to the top of the stack, and move to the close-brackets
      % state, ready for next time (unless inbrackets resets it).  If we come
      % into this branch, then output.state is carefully undisturbed.
      bracket.state open.brackets =
        { " [" * }
        { ", " * } % bracket.state will be within.brackets
      if$
      s *
      close.brackets 'bracket.state :=
    }
  if$
}

% Call this function just before adding something which should be presented in
% brackets.  bracket.state is handled specially within output.nonnull.
FUNCTION {inbrackets}
{ bracket.state close.brackets =
    { within.brackets 'bracket.state := } % reset the state: not open nor closed
    { open.brackets 'bracket.state := }
  if$
}

FUNCTION {enclose.brackets}
{ "[" swap$ * "]" *
}

STRINGS { iso.month }

FUNCTION {format.iso.month}
{ #6 #2 substring$ 'iso.month :=
  iso.month "01" =
    { "Jan" }
    {
  iso.month "02" =
    { "Feb" }
    {
  iso.month "03" =
    { "Mar" }
    {
  iso.month "04" =
    { "Apr" }
    {
  iso.month "05" =
    { "May" }
    {
  iso.month "06" =
    { "Jun" }
    {
  iso.month "07" =
    { "Jul" }
    {
  iso.month "08" =
    { "Aug" }
    {
  iso.month "09" =
    { "Sep" }
    {
  iso.month "10" =
    { "Oct" }
    {
  iso.month "11" =
    { "Nov" }
    {
  iso.month "12" =
    { "Dec" }
    { "Invalid month " quote$ * iso.month * quote$ * " in " * cite$ * warning$ iso.month }
  if$
    }
  if$
    }
  if$
    }
  if$
    }
  if$
    }
  if$
    }
  if$
    }
  if$
    }
  if$
    }
  if$
    }
  if$
    }
  if$
}

% "2021-04-01" -> "2021 Apr 1"
FUNCTION {format.iso.date}
{ duplicate$ text.length$ #10 =
    { duplicate$ #1 #4 substring$ " " *
      swap$ duplicate$ format.iso.month " " *
      swap$
      duplicate$ #9 #1 substring$ "0" =
        { #10 #1 substring$ }
        { #9 #2 substring$ }
      if$
      * *
    }
    { duplicate$ "Invalid date " quote$ * swap$ * quote$ *
      " in " * cite$ * warning$
    }
  if$
}

FUNCTION {format.urldate}
{ urldate empty$
    { lastchecked empty$
        { "" }
        { "cited " lastchecked * enclose.brackets }
      if$
    }
    { "cited "
      urldate format.iso.date *
      enclose.brackets
    }
  if$
}
% ...urlbst to here

FUNCTION {output}
{ duplicate$ empty$
    'pop$
    'output.nonnull
  if$
}

FUNCTION {output.check}
{ 't :=
  duplicate$ empty$
    { pop$ "empty " t * " in " * cite$ * warning$ }
    'output.nonnull
  if$
}

FUNCTION {fin.entry}
{
  bracket.state close.brackets = % urlbst
    { "]" * }
    'skip$
  if$
  language empty$
    'skip$
    { language "l" change.case$ "english" =
        'skip$
        { " [" *
          language #1 #1 substring$ "u" change.case$ *
          language #2 global.max$ substring$ "l" change.case$ *
          "]" *
        }
      if$
    }
  if$
  url empty$
    'add.period$
    'skip$
  if$
  write$
  newline$
}

FUNCTION {new.block}
{ output.state before.all =
    'skip$
    { after.block 'output.state := }
  if$
}

FUNCTION {new.sentence}
{ output.state after.block =
    'skip$
    { output.state before.all =
        'skip$
        { after.sentence 'output.state := }
      if$
    }
  if$
}

FUNCTION {add.blank}
{  " " * before.all 'output.state :=
}

FUNCTION {no.blank.or.punct}
{  "" * before.all 'output.state :=
}

FUNCTION {add.semicolon}
{
  ";" *
  no.blank.or.punct
}

FUNCTION {add.colon}
{
  ":" *
  no.blank.or.punct
}

FUNCTION {date.block}
{
  "." *
  no.blank.or.punct
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            LOGICAL `NOT', `AND', AND `OR'                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Logical 'not':
% If the first element on the stack is A then this function
% does the following:
%     push { #0 }
%     push { #1 }
% So now the first 3 elements of the stack are
%     { #1 } { #0 } A
% The first 3 are popped and subjected to 'if':
% If A > 0 then { #0 } is executed, else { #1 } is executed:
%     if A > 0
%     then 0
%     else 1
% So consider integers as logicals, where 1 = true and 0 = false,
% then this does
%     (if A then false else true)
% which is a logical 'not'.

FUNCTION {not}
{   { #0 }
    { #1 }
  if$
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Logical 'and':
% If the first 2 elements on the stack are A B
% then this function does the following:
%     push 'skip$
%     push { pop$ #0 }
% So now first 4 elements are
%     { pop$ #0 } 'skip$ A B
% The first 3 are popped and subjected to 'if' (B is on top of
% the stack):
% If A > 0 then 'skip$ is executed, else { pop$ #0 } is executed:
%     if A > 0
%     then (B stays on top of stack)
%     else (B is popped and #0 is pushed)
% So consider integers as logicals, where 1 = true and 0 = false,
% then this does
%     (if A then B else false)
% which is a logical 'and'.

FUNCTION {and}
{   'skip$
    { pop$ #0 }
  if$
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Logical 'or':
% If the first 2 elements on the stack are A B
% then this function does the following:
%     push { pop$ #1 }
%     push 'skip$
% So now first 4 elements are
%     'skip$ { pop$ #1 } A B
% The first 3 are popped and subjected to 'if' (B is on top of
% the stack):
% If A > 0 then { pop$ #1 } is executed, else 'skip$ is executed:
%     if A > 0
%     then (B is popped and #1 is pushed)
%     else (B stays on top of stack)
% So consider integers as logicals, where 1 = true and 0 = false,
% then this does
%     (if A then true else B)
% which is a logical 'or'.

FUNCTION {or}
{   { pop$ #1 }
    'skip$
  if$
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  GENERAL PURPOSE FUNCTIONS FOR FORMATTING                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% issues warning if field is empty
% call with
%    "field"  field  warning.if.empty
% Note that the first field must be between quotes
% because it is the fieldname for use in the warning message.
%

FUNCTION {warning.if.empty}
{ empty$
    { "No "  swap$ * " in " * cite$ * warning$ }
    { pop$ }
  if$
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % encloses string in pre- and postfix string
    % call with
    %    prefix postfix  S  enclose.check
    % delivers empty string if S empty
    %
FUNCTION {enclose.check}
{ duplicate$ empty$
    { pop$ pop$ pop$
      ""
    }
    { swap$ * * }
  if$
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% emphasizes top of stack
% call with
%    string" emphasize.check
%

FUNCTION {emphasize.check}
{ "\Bem{" swap$
  "}"     swap$
  enclose.check
}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % brackets top of stack
    % call with
    %     "string" bracket.check
    %
FUNCTION {bracket.check}
{ "[" swap$
  "]" swap$
  enclose.check
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % parenthesizes top of stack
    % call with
    %     "string" parenthesize
    %
FUNCTION {parenthesize.check}
{ "(" swap$
  ")" swap$
  enclose.check
}

STRINGS {z}

FUNCTION {remove.dots}
{ 'z :=	% expects string on top of the stack, pops the string and assigns it to variable z
  "" % push empty string
  { z empty$ not } % returns 0 if variable z is empty
  { z #1 #1 substring$ % push the first character of variable z
    z #2 global.max$ substring$ 'z := % assigns the 2nd to last character of variable z to variable z
    duplicate$ "\" = % pushes 1 if the last character is "\", otherwise 0
    { * % concatenates the last 2 literals
      z #1 #1 substring$ % push the first character of variable z
      z #2 global.max$ substring$ 'z := % assigns the 2nd to last character of variable z to variable z
      * % concatenates the last 2 literals, i.e. every character, even a dot, following a "\" will be printed
    }
    { duplicate$ "." = % pushes 1 if the last character is ".", otherwise 0
      'pop$ %  pushes the pop$ function
      { * } % concatenates the last 2 literals
    if$ % pops the last character if it is a dot, otherwise concatenates it with the string on top of the stack
    }
    if$
  }
  while$
}

INTEGERS {l}
FUNCTION{string.length}
{
  #1 'l :=
  { duplicate$ duplicate$ #1 l substring$ = not }
    { l #1 + 'l := }
  while$
  pop$ l
}

STRINGS {replace find text}
INTEGERS {find_length}
FUNCTION {find.replace}
{
  'replace :=
  'find :=
  'text :=
  find string.length 'find_length :=
  ""
    { text empty$ not }
    { text #1 find_length substring$ find =
      {
        replace *
        text #1 find_length + global.max$ substring$ 'text :=
      }
      { text #1 #1 substring$ *
        text #2  global.max$ substring$ 'text :=
      }
    if$
    }
  while$
}

FUNCTION {new.block.checka}
{ empty$
    'skip$
    'new.block
  if$
}

FUNCTION {new.block.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.block
  if$
}

FUNCTION {new.sentence.checka}
{ empty$
    'skip$
    'new.sentence
  if$
}

FUNCTION {new.sentence.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.sentence
  if$
}

FUNCTION {field.or.null}
{ duplicate$ empty$
    { pop$ "" }
    'skip$
  if$
}

FUNCTION {emphasize}
{ duplicate$ empty$
    { pop$ "" }
    { "\emph{" swap$ * "}" * }
  if$
}

FUNCTION {tie.or.space.prefix}
{ duplicate$ text.length$ #3 <
    { "~" }
    { " " }
  if$
  swap$
}

FUNCTION {capitalize}
{ "u" change.case$ "t" change.case$ }

FUNCTION {space.word}
{ " " swap$ * " " * }

 % Here are the language-specific definitions for explicit words.
 % Each function has a name bbl.xxx where xxx is the English word.
 % The language selected here is ENGLISH

FUNCTION {bbl.and}
{ "and"}

FUNCTION {bbl.etal}
{ "et~al." }

FUNCTION {bbl.editors}
{ "editors" }

FUNCTION {bbl.editor}
{ "editor" }

FUNCTION {bbl.cartographers}
{ "cartographers" }

FUNCTION {bbl.cartographer}
{ "cartographer" }

FUNCTION {bbl.inventors}
{ "inventors" }

FUNCTION {bbl.inventor}
{ "inventor" }

FUNCTION {bbl.assignees}
{ "assignees" }

FUNCTION {bbl.assignee}
{ "assignee" }

FUNCTION {bbl.edby}
{ "edited by" }

FUNCTION {bbl.edition}
{ "ed." }

FUNCTION {bbl.volume}
{ "vol." }

FUNCTION {bbl.of}
{ "of" }

FUNCTION {bbl.number}
{ "no." }

FUNCTION {bbl.nr}
{ "no." }

FUNCTION {bbl.in}
{ "in" }

FUNCTION {bbl.pages}
{ "p." }

FUNCTION {bbl.page}
{ "p." }

FUNCTION {bbl.chapter}
{ "chap." }

FUNCTION {bbl.techrep}
{ "Tech. Rep." }

FUNCTION {bbl.mthesis}
{ "Master's thesis" }

FUNCTION {bbl.phdthesis}
{ "Ph.D. thesis" }

FUNCTION {bbl.first}
{ "1st" }

FUNCTION {bbl.second}
{ "2nd" }

FUNCTION {bbl.third}
{ "3rd" }

FUNCTION {bbl.fourth}
{ "4th" }

FUNCTION {bbl.fifth}
{ "5th" }

FUNCTION {bbl.st}
{ "st" }

FUNCTION {bbl.nd}
{ "nd" }

FUNCTION {bbl.rd}
{ "rd" }

FUNCTION {bbl.th}
{ "th" }

MACRO {jan} {"Jan"}

MACRO {feb} {"Feb"}

MACRO {mar} {"Mar"}

MACRO {apr} {"Apr"}

MACRO {may} {"May"}

MACRO {jun} {"Jun"}

MACRO {jul} {"Jul"}

MACRO {aug} {"Aug"}

MACRO {sep} {"Sep"}

MACRO {oct} {"Oct"}

MACRO {nov} {"Nov"}

MACRO {dec} {"Dec"}

FUNCTION {eng.ord}
{ duplicate$ "1" swap$ *
  #-2 #1 substring$ "1" =
     { bbl.th * }
     { duplicate$ #-1 #1 substring$
       duplicate$ "1" =
         { pop$ bbl.st * }
         { duplicate$ "2" =
             { pop$ bbl.nd * }
             { "3" =
                 { bbl.rd * }
                 { bbl.th * }
               if$
             }
           if$
          }
       if$
     }
   if$
}

FUNCTION {bibinfo.check}
{ swap$
  duplicate$ missing$
    {
      pop$ pop$
      ""
    }
    { duplicate$ empty$
        {
          swap$ pop$
        }
        { swap$
          pop$
        }
      if$
    }
  if$
}

FUNCTION {bibinfo.warn}
{ swap$
  duplicate$ missing$
    {
      swap$ "missing " swap$ * " in " * cite$ * warning$ pop$
      ""
    }
    { duplicate$ empty$
        {
          swap$ "empty " swap$ * " in " * cite$ * warning$
        }
        { swap$
          pop$
        }
      if$
    }
  if$
}

STRINGS  { bibinfo}
INTEGERS { nameptr namesleft numnames }

FUNCTION {format.names}
{ 'bibinfo :=
  duplicate$ empty$ 'skip$ {
  "." ". " find.replace 's :=
  "" 't :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { s nameptr
      "{vv~}{ll}{ f{}}{ jj}"
      format.name$
      remove.dots
      bibinfo bibinfo.check
      't :=
      nameptr #1 >
        {
          nameptr #3
          #1 + =
          numnames #3
          > and
            { "others" 't :=
              #1 'namesleft := }
            'skip$
          if$
          namesleft #1 >
            { ", " * t * }
            {
              "," *
              s nameptr "{ll}" format.name$ duplicate$ "others" =
                { 't := }
                { pop$ }
              if$
              t "others" =
                {
                  " " * bbl.etal *
                }
                { " " * t * }
              if$
            }
          if$
        }
        't
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
  } if$
}

FUNCTION {format.names.org}
{ 'bibinfo :=
  duplicate$ empty$ 'skip$ {
  's :=
  "" 't :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { s nameptr
      "{ff~}{vv~}{ll}"
      format.name$
      bibinfo bibinfo.check
      't :=
      nameptr #1 >
        {
          namesleft #1 >
            { "; " * t * }
            {
              ";" *
              s nameptr "{ll}" format.name$ duplicate$ "others" =
                { 't := }
                { pop$ }
              if$
              t "others" =
                {
                  " " * bbl.etal *
                }
                { " " * t * }
              if$
            }
          if$
        }
        't
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
  } if$
}

FUNCTION {format.names.ed}
{
  format.names
}

FUNCTION {format.authors}
{
  author "author" format.names
  %%"." " " "author" find.replace format.names
}

FUNCTION {format.organizations}
{ organization "organization" format.names.org
}

FUNCTION {get.bbl.editor}
{ editor num.names$ #1 > 'bbl.editors 'bbl.editor if$ }

FUNCTION {get.bbl.cartographer}
{ cartographer num.names$ #1 > 'bbl.cartographers 'bbl.cartographer if$ }

FUNCTION {get.bbl.inventor}
{ inventor num.names$ #1 > 'bbl.inventors 'bbl.inventor if$ }

FUNCTION {get.bbl.assignee}
{ assignee num.names$ #1 > 'bbl.assignees 'bbl.assignee if$ }

FUNCTION {format.editors}
{ editor "editor" format.names duplicate$ empty$ 'skip$
    {
      "," *
      " " *
      get.bbl.editor
      *
    }
  if$
}

FUNCTION {format.assignees}
{ assignee "assignee" format.names.org duplicate$ empty$ 'skip$
    {
      "," *
      " " *
      get.bbl.assignee
      *
    }
  if$
}

FUNCTION {format.cartographers}
{ cartographer "cartographer" format.names duplicate$ empty$ 'skip$
    {
      "," *
      " " *
      get.bbl.cartographer
      *
    }
  if$
}

FUNCTION {format.inventors}
{ inventor "inventor" format.names duplicate$ empty$ 'skip$
    {
      "," *
      " " *
      get.bbl.inventor
      *
    }
  if$
}

FUNCTION {format.note}
{
 note empty$
    { "" }
    { note #1 #1 substring$
      duplicate$ "{" =
        'skip$
        { output.state mid.sentence =
          { "l" }
          { "u" }
        if$
        change.case$
        }
      if$
      note #2 global.max$ substring$ * "note" bibinfo.check
    }
  if$
}

FUNCTION {format.title}
{ title
%%duplicate$ empty$ 'skip$
%%  { "t" change.case$ }
%%if$
  "title" bibinfo.check
}

FUNCTION {format.type}
{ type empty$
    'skip$
    { inbrackets type }
    %%{ add.blank "[" type * "]" * }
  if$
}

FUNCTION {format.full.names}
{'s :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { s nameptr
      "{vv~}{ll}" format.name$ 't :=
      nameptr #1 >
        {
          namesleft #1 >
            { ", " * t * }
            {
              numnames #2 >
                { "," * }
                'skip$
              if$
              t "others" =
                { " et~al." * }
                { " and " * t * }
              if$
            }
          if$
        }
        't
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}

FUNCTION {author.editor.full}
{ author empty$
    { editor empty$
        { "" }
        { editor format.full.names }
      if$
    }
    { author format.full.names }
  if$
}

FUNCTION {author.full}
{ author empty$
    { "" }
    { author format.full.names }
  if$
}

FUNCTION {editor.full}
{ editor empty$
    { "" }
    { editor format.full.names }
  if$
}

FUNCTION {make.full.names}
{ type$ "book" =
  type$ "inbook" =
  or
    'author.editor.full
    { type$ "proceedings" =
        'editor.full
        'author.full
      if$
    }
  if$
}

FUNCTION {output.bibitem}
{ outside.brackets 'bracket.state := % urlbst
   newline$
  "\bibitem[" write$
  label write$
  ")" make.full.names duplicate$ short.list =
     { pop$ }
     { * }
   if$
  "]{" * write$
  cite$ write$
  "}" write$
  newline$
  ""
  before.all 'output.state :=
}

FUNCTION {hyphenate}
{ 't :=
  ""
    { t empty$ not }
    { t #1 #1 substring$ "-" =
        { "-" *
            { t #1 #1 substring$ "-" = }
            { t #2 global.max$ substring$ 't := }
          while$
        }
        { t #1 #1 substring$ *
          t #2 global.max$ substring$ 't :=
        }
      if$
    }
  while$
}

FUNCTION {word.in}
{ bbl.in capitalize
  ":" *
  " " * }

FUNCTION {format.journal.date}
{ date empty$
    { type$ "patent" =
        { quote$ date * quote$ * " is required in patent." * warning$}
        'skip$
      if$
      year empty$
        { "" }
        { year
          month empty$
            'skip$
            { " " *
              month *
            }
          if$
        }
      if$
    }
    { date format.iso.date }
  if$
}

FUNCTION {format.year}
{
  no.blank.or.punct
  ";"
  duplicate$ empty$
  year  "year"  bibinfo.check duplicate$ empty$
    { swap$ 'skip$
        { "there's a month but no year in " cite$ * warning$ }
      if$
      *
    }
    { swap$ 'skip$
        {
          swap$
          " " * swap$
        }
      if$
      *
    }
  if$
}

FUNCTION {format.journal}
{ journal
  remove.dots
  emphasize
  "journal" bibinfo.check
}

FUNCTION {format.btitle}
{ title "title" bibinfo.check
  duplicate$ empty$
    'skip$
    { eventtitle empty$
        { emphasize }
        'skip$
      if$
    }
  if$
}

FUNCTION {either.or.check}
{ empty$
    'pop$
    { "can't use both " swap$ * " fields in " * cite$ * warning$ }
  if$
}

FUNCTION {format.bvolume}
{ volume empty$
    { "" }
    { bbl.volume volume tie.or.space.prefix
      "volume" bibinfo.check * *
      series "series" bibinfo.check
      duplicate$ empty$ 'pop$
        { swap$ bbl.of space.word * swap$
          emphasize * }
      if$
      "volume and number" number either.or.check
    }
  if$
}

FUNCTION {format.number.series}
{ volume empty$
    { number empty$
        { series field.or.null }
        { series empty$
            { number "number" bibinfo.check }
        { output.state mid.sentence =
            { bbl.number }
            { bbl.number capitalize }
          if$
          number tie.or.space.prefix "number" bibinfo.check * *
          bbl.in space.word *
          series "series" bibinfo.check *
        }
      if$
    }
      if$
    }
    { "" }
  if$
}

FUNCTION {is.num}
{ chr.to.int$
  duplicate$ "0" chr.to.int$ < not
  swap$ "9" chr.to.int$ > not and
}

FUNCTION {extract.num}
{ duplicate$ 't :=
  "" 's :=
  { t empty$ not }
  { t #1 #1 substring$
    t #2 global.max$ substring$ 't :=
    duplicate$ is.num
      { s swap$ * 's := }
      { pop$ "" 't := }
    if$
  }
  while$
  s empty$
    'skip$
    { pop$ s }
  if$
}

FUNCTION {convert.edition}
{ extract.num "l" change.case$ 's :=
  s "first" = s "1" = or
    { bbl.first 't := }
    { s "second" = s "2" = or
        { bbl.second 't := }
        { s "third" = s "3" = or
            { bbl.third 't := }
            { s "fourth" = s "4" = or
                { bbl.fourth 't := }
                { s "fifth" = s "5" = or
                    { bbl.fifth 't := }
                    { s #1 #1 substring$ is.num
                        { s eng.ord 't := }
                        { edition 't := }
                      if$
                    }
                  if$
                }
              if$
            }
          if$
        }
      if$
    }
  if$
  t
}

FUNCTION {format.edition}
{ edition duplicate$ empty$ 'skip$
    {
      convert.edition
      output.state mid.sentence =
        { "l" }
        { "t" }
      if$ change.case$
      "edition" bibinfo.check
      " " * bbl.edition *
    }
  if$
}
INTEGERS { multiresult }
FUNCTION {multi.page.check}
{ 't :=
  #0 'multiresult :=
    { multiresult not
      t empty$ not
      and
    }
    { t #1 #1 substring$
      duplicate$ "-" =
      swap$ duplicate$ "," =
      swap$ "+" =
      or or
        { #1 'multiresult := }
        { t #2 global.max$ substring$ 't := }
      if$
    }
  while$
  multiresult
}

FUNCTION {is.letter}
{ duplicate$ empty$
    { pop$ #0 }
    { chr.to.int$
      duplicate$ "A" chr.to.int$ <
        { pop$ #0 }
        { duplicate$ "Z" chr.to.int$ >
            { duplicate$ "a" chr.to.int$ <
                { pop$ #0 }
                { duplicate$ "z" chr.to.int$ >
                    { pop$ #0 }
                    { pop$ #1 }
                  if$
                }
              if$
            }
            { pop$ #1 }
          if$
        }
      if$
    }
  if$
}

FUNCTION {is.digit}
{ duplicate$ empty$
    { pop$ #0 }
    { chr.to.int$
      duplicate$ "0" chr.to.int$ <
        { pop$ #0 }
        { "9" chr.to.int$ >
            { #0 }
            { #1 }
          if$
        }
      if$
    }
  if$
}

FUNCTION {is.letter.digit}
{ duplicate$ is.letter
  swap$ is.digit or
}

INTEGERS { charptr len }

STRINGS { start.number end.number range.separator }

FUNCTION {abbreviate.range.numbers}
{ end.number end.number text.length$ #1 substring$ is.letter
    { start.number range.separator * end.number * }
    { end.number text.length$ 'len :=
      start.number text.length$ len <
        'skip$
        { start.number text.length$ len - #1 + 'charptr :=
            { end.number text.length$ #1 >
              start.number charptr #1 substring$
              end.number #1 #1 substring$ = and
            }
            { charptr #1 + 'charptr :=
              end.number #2 global.max$ substring$ 'end.number :=
            }
          while$
        }
      if$
      start.number range.separator * end.number *
    }
  if$
}

% This a helper function for use in format.page.numbers
FUNCTION {append.pages.part}
{ duplicate$ duplicate$ text.length$ #1 substring$ "," =
    { " " * }
    'skip$
  if$
  end.number empty$
    { start.number empty$
        'skip$
        { start.number * }
      if$
    }
    { abbreviate.range.numbers * }
  if$
  "" 'start.number :=
  "" 'end.number :=
  "" 'range.separator :=
}

FUNCTION {format.page.numbers}
{ 's :=
  "" 't :=
  "" 'start.number :=
  "" 'end.number :=
  "" 'range.separator :=
  ""
    { s empty$ not }
    { s #1 #1 substring$ 't :=
      t is.letter.digit
        { range.separator empty$
            { start.number t * 'start.number := }
            { end.number t * 'end.number := }
          if$
        }
        { s #1 #2 substring$ "--" =
            { "--" 'range.separator := }
            { t "-" =
                { "-" 'range.separator := }
                { append.pages.part
                  t *
                }
              if$
            }
          if$
        }
      if$
      s #2 global.max$ substring$ 's :=
    }
  while$
  append.pages.part
}

FUNCTION {format.pages}
{ pages duplicate$ empty$ 'skip$
    { duplicate$ multi.page.check
        {
          format.page.numbers
          bbl.pages swap$
          hyphenate
        }
        {
          bbl.page swap$
        }
      if$
      tie.or.space.prefix
      "pages" bibinfo.check
      * *
    }
  if$
}

FUNCTION {format.journal.pages}
{ pages empty$ 'skip$
  { add.colon }
  if$
  pages duplicate$ empty$ 'pop$
  {
    format.page.numbers
    hyphenate
    "pages" bibinfo.check
    *
  }
  if$
}

FUNCTION {format.vol.num}
{ volume field.or.null
  duplicate$ empty$ 'skip$
    {
      "volume" bibinfo.check
    }
  if$
  number "number" bibinfo.check duplicate$ empty$ 'skip$
    {
      swap$ duplicate$ empty$
        { "there's a number but no volume in " cite$ * warning$ }
        'skip$
      if$
      swap$
      "(" swap$ * ")" *
    }
  if$ *
}

FUNCTION {format.vol.num.pages}
{ volume empty$ number empty$ and
    'skip$
    { add.semicolon }
  if$
  volume field.or.null
  duplicate$ empty$ 'skip$
    {
      "volume" bibinfo.check
    }
  if$
  number "number" bibinfo.check duplicate$ empty$ 'skip$
    {
      swap$ duplicate$ empty$
        { "there's a number but no volume in " cite$ * warning$ }
        'skip$
      if$
      swap$
      "(" swap$ * ")" *
    }
  if$ *
  format.journal.pages
}

FUNCTION {format.chapter.pages}
{ chapter empty$
    'format.pages
    { type empty$
        { bbl.chapter }
		{ type "l" change.case$
		  "type" bibinfo.check
		}
	      if$
	      chapter tie.or.space.prefix
	      "chapter" bibinfo.check
	      * *
	      pages empty$
		'skip$
		{ ", " * format.pages * }
	      if$
	    }
	  if$
	}

	FUNCTION {format.booktitle}
	{
	  booktitle
    eventtitle empty$
      { emphasize }
      'skip$
    if$
    "booktitle" bibinfo.check
	}

	FUNCTION {format.in.ed.booktitle}
	{ format.booktitle duplicate$ empty$ 'skip$
	    {
	      editor "editor" format.names.ed duplicate$ empty$ 'pop$
		{
		  "," *
		  " " *
		  get.bbl.editor
		  ". " *
		  * swap$
		  * }
	      if$
	      word.in swap$ *
	    }
	  if$
	}

	FUNCTION {format.in.ed.title}
	{ format.title duplicate$ empty$ 'skip$
	    {
	      editor "editor" format.names.ed duplicate$ empty$ 'pop$
		{
		  "," *
		  " " *
		  get.bbl.editor
		  ". " *
		  * swap$
		  * }
	      if$
	      word.in swap$ *
	    }
	  if$
	}

	FUNCTION {empty.misc.check}
	{ author empty$ title empty$ howpublished empty$
	  month empty$ year empty$ note empty$
	  and and and and and
	    { "all relevant fields are empty in " cite$ * warning$ }
	    'skip$
	  if$
	}
	FUNCTION {format.thesis.type}
	{ type duplicate$ empty$
	    'pop$
	    { swap$ pop$
	      "t" change.case$ "type" bibinfo.check
    }
  if$
}
FUNCTION {format.tr.number}
{
  number "number" bibinfo.check
  duplicate$ empty$
    { pop$ "" }
    { type$ "techreport" =
        { "Report No.: " }
        { "" }
      if$
      swap$ *
    }
  if$
  %%type duplicate$ empty$
    %%{ pop$ bbl.techrep }
    %%'skip$
  %%if$
  %%"type" bibinfo.check
  %%swap$ duplicate$ empty$
    %%{ pop$ "t" change.case$ }
    %%{ tie.or.space.prefix * * }
  %%if$
}

FUNCTION {format.org.or.pub}
{ 't :=
  ""
  address empty$ t empty$ and
    'skip$
    {
      address "address" bibinfo.check *
      t empty$
        'skip$
        { address empty$
            'skip$
            { ": " * }
          if$
          t *
        }
      if$
    }
  if$
}

FUNCTION {format.publisher.address}
{ publisher "publisher" bibinfo.warn format.org.or.pub
}

FUNCTION {format.organization.address}
{ organization "organization" bibinfo.check format.org.or.pub
}

FUNCTION {format.institution.address}
{ institution "institution" bibinfo.check format.org.or.pub
}

FUNCTION {format.school.address}
{ school "school" bibinfo.check format.org.or.pub
}


% urlbst...
% Functions for making hypertext links.
% In all cases, the stack has (link-text href-url)
%
% make 'null' specials
FUNCTION {make.href.null}
{
  pop$
}
% make hypertex specials
FUNCTION {make.href.hypertex}
{
  "\special {html:<a href=" quote$ *
  swap$ * quote$ * "> }" * swap$ *
  "\special {html:</a>}" *
}
% make hyperref specials
FUNCTION {make.href.hyperref}
{
  "\href {" swap$ * "} {" * swap$ * "}" *
}
FUNCTION {make.href}
{ hrefform #2 =
    'make.href.hyperref      % hrefform = 2
    { hrefform #1 =
        'make.href.hypertex  % hrefform = 1
        'make.href.null      % hrefform = 0 (or anything else)
      if$
    }
  if$
}

FUNCTION {format.url}
{ url empty$
    { "" }
      { hrefform #1 =
          { % special case -- add HyperTeX specials
            urlintro "\url{" url * "}" * url make.href.hypertex * }
          { urlintro "\url{" * url * "}" * }
       if$
     }
  if$
}

FUNCTION {format.eprint}
{ eprint empty$
    { "" }
    { eprintprefix eprint * eprinturl eprint * make.href }
  if$
}

FUNCTION {format.doi}
{ doi empty$
    { "" }
    { doiprefix doi * doiurl doi * make.href }
  if$
}

% Output a URL.  We can't use the more normal idiom (something like
% `format.url output'), because the `inbrackets' within
% format.urldate applies to everything between calls to `output',
% so that `format.url format.urldate * output' ends up with both
% the URL and the lastchecked in brackets.
FUNCTION {output.url}
{ url empty$
    'skip$
    { new.block
      format.url output
    }
  if$
}

FUNCTION {output.web.refs}
{
  new.block
  output.url
  addeprints eprint empty$ not and
    { format.eprint output.nonnull }
    'skip$
  if$
  adddoiresolver doi empty$ not and
    { format.doi output.nonnull }
    'skip$
  if$
%  addeprints
%    { eprint empty$
%        'skip$
%        { format.eprint output.nonnull }
%      if$
%    }
%    'skip$
%  if$
}

% Webpage entry type.
% Title and url fields required;
% author, note, year, month, and lastchecked fields optional
STRINGS {database}
FUNCTION {webpage}
{ output.bibitem
  author empty$
    { editor empty$
        'skip$  % author and editor both optional
        { format.editors output.nonnull }
      if$
    }
    { editor empty$
        { format.authors output.nonnull }
        { "can't use both author and editor fields in " cite$ * warning$ }
      if$
    }
  if$
%  author empty$
%    'skip$
%    { format.authors output.nonnull }
%  if$
  new.block
  format.title "title" output.check
  type empty$ not
    { format.type "type" output.check }
    'skip$
  if$
  publisher empty$
    'skip$
    { format.publisher.address output }
  if$
  "database on the Internet" 'database :=
  type empty$ not
    { type database =
        { format.journal.date "year" output.check }
        { format.year "year" output.check }
      if$
    }
    { format.year "year" output.check }
  if$
  lastchecked empty$ urldate empty$ and
    'skip$
    { format.urldate output }
  if$
  new.block
  part empty$
    'skip$
    { part output }
  if$
  pages empty$
    'skip$
    { pages bracket.check output }
  if$
  format.url "url" output.check
  new.block
  note output
  fin.entry
}

FUNCTION {preprint}
{ output.bibitem
  author empty$
    { editor empty$
        'skip$  % author and editor both optional
        { format.editors output.nonnull }
      if$
    }
    { editor empty$
        { format.authors output.nonnull }
        { "can't use both author and editor fields in " cite$ * warning$ }
      if$
    }
  if$
%  author empty$
%    'skip$
%    { format.authors output.nonnull }
%  if$
  new.block
  format.title "title" output.check
  new.block
  booktitle empty$ not
    { booktitle output
      eventtitle empty$ not
        { new.block
          eventtitle
          booktitle empty$
            'emphasize
            'skip$
          if$
          output
        }
        'skip$
      if$
      "; " eventdate * *
      "; " venue * *
      new.block
      year empty$ not
        { year output }
        'skip$
      if$
      new.sentence
      format.pages "pages" output.check
      new.block
    }
    'skip$
  if$
  archiveprefix empty$ not
    { archiveprefix }
    { eprinttype empty$ not
        { eprinttype }
        { journal empty$ not
            { journal }
            { "" archiveprefix * pop$ }
          if$
        }
      if$
    }
  if$
  " " *
  elocation-id empty$ not
    { elocation-id }
    { eprint }
  if$
  * " [Preprint]" * output
  new.block
  format.journal.date
  urldate empty$ not
    { " " * format.urldate * }
    'skip$
  if$
  output
  new.block
  format.url "url" output.check
  new.block
  lastchecked empty$ urldate empty$ and
    'skip$
    { format.urldate output }
  if$
  new.block
  note output
  fin.entry
}
% ...urlbst to here

FUNCTION {online} { webpage }

FUNCTION {misc}
{ output.bibitem
  format.authors "author" output.check
  format.editors "author and editor" output.check
  format.title "title" output.check
  type missing$
    { skip$ }
    { format.type "type" output.check }
    %%{ inbrackets type output }
  if$
  format.publisher.address output
  format.year "year" output.check
  new.block
  format.note output
  new.block
  howpublished new.block.checka
  howpublished "howpublished" bibinfo.check output
  output.web.refs  % urlbst
  fin.entry
  empty.misc.check
}

FUNCTION {journal.article}
{ output.bibitem
  format.authors "author" output.check
  organization empty$
    'skip$
    { author empty$
        {
          format.organizations "organization" output.check
	}
	{
	  "; " *
	  no.blank.or.punct
          format.organizations "organization" output.check
	}
      if$
    }
  if$
  new.block
  format.title "title" output.check
  new.block
  format.journal "journal" output.check
  url empty$
    { add.blank }
    'skip$
  if$
  format.journal.date
  lastchecked empty$ urldate empty$ and
    'skip$
    { " " * format.urldate * }
  if$
  "year" output.check
  format.vol.num.pages output
  new.block
  format.note output
  output.web.refs  % urlbst
  fin.entry
}

FUNCTION {article}
{ eprint empty$
    { journal.article }
    { preprint }
  if$
}

FUNCTION {book}
{ output.bibitem
  author empty$
    { editor empty$
        { format.organizations "organization" output.check }
        { format.editors "author and editor" output.check }
      if$
    }
    { format.authors output.nonnull
      "author and editor" editor either.or.check
    }
  if$
  new.block
  format.btitle "title" output.check
  format.bvolume output
  new.block
  format.edition output
  new.sentence
  author empty$ not
  editor empty$ not
  and
    { format.editors "author and editor" output.check }
      'skip$
  if$
  format.number.series output
  format.publisher.address output
  format.year
  lastchecked empty$ urldate empty$ and
    'skip$
    { " " * format.urldate * }
  if$
  "year" output.check
  format.pages "pages" output.check
  new.block
  format.note output
  output.web.refs  % urlbst
  fin.entry
}

FUNCTION {booklet}
{ misc }

FUNCTION {dictionary}
{ output.bibitem
  format.booktitle "booktitle" output.check
  format.bvolume output
  new.block
  format.edition output
  new.sentence
  format.publisher.address output
  format.year "year" output.check
  format.btitle "title" output.check
  add.semicolon
  add.blank
  format.pages "pages" output.check
  new.block
  format.note output
  output.web.refs  % urlbst
  fin.entry
}

FUNCTION {inbook}
{ output.bibitem
  format.authors "author" output.check
  new.block
  chapter "chapter" output.check
  new.block
  format.in.ed.title "title" output.check
  format.bvolume output
  format.edition output
  new.sentence
  format.number.series output
  format.publisher.address output
  format.year "year" output.check
  date.block
  add.blank
  format.pages "pages" output.check
  new.block
  format.note output
  output.web.refs  % urlbst
  fin.entry
}

FUNCTION {incollection}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  format.in.ed.booktitle "booktitle" output.check
  format.bvolume output
  format.edition output
  new.sentence
  format.number.series output
  format.publisher.address output
  format.year "year" output.check
  date.block
  add.blank
  format.pages "pages" output.check
  new.block
  format.note output
  output.web.refs  % urlbst
  fin.entry
}

FUNCTION {inproceedings}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  "" editor * pop$
  format.in.ed.booktitle "booktitle" output.check
  eventtitle empty$ not
    { new.block
      eventtitle emphasize
      output
    }
    'skip$
  if$
  eventdate empty$
    'skip$
    { "; " eventdate * * }
  if$
  venue empty$
    'skip$
    { "; " venue * * }
  if$
  new.block
  publisher empty$
    { format.organization.address output }
    { organization "organization" bibinfo.check output
      format.publisher.address output
    }
  if$
  format.year "year" output.check
  date.block
  add.blank
  "" pages * pop$
  format.pages "pages" output.check
  new.block
  format.note output
  output.web.refs  % urlbst
  fin.entry
}

FUNCTION {conference}
{inproceedings}

FUNCTION {manual}
{misc}

FUNCTION {phdthesis}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title
  "title" output.check
  format.type "type" output.check
  new.block
  format.school.address output
  format.year "year" output.check
  new.block
  format.note output
  output.web.refs  % urlbst
  fin.entry
}

FUNCTION {mastersthesis}
{phdthesis}

FUNCTION {proceedings}
{ output.bibitem
  editor empty$
    { organization "organization" bibinfo.check output
    }
    { format.editors output.nonnull }
  if$
  new.block
  format.btitle "title" output.check
  format.bvolume output
  eventtitle empty$ not
    { eventtitle emphasize
      output
    }
    'skip$
  if$
  eventdate empty$
    'skip$
    { "; " eventdate * * }
  if$
  venue empty$
    'skip$
    { "; " venue * * }
  if$
  editor empty$
    { publisher empty$
        'skip$
        {
          new.sentence
          format.number.series output
          format.publisher.address output
        }
      if$
    }
    { publisher empty$
        {
          new.sentence
          format.organization.address output }
        {
          new.sentence
          organization "organization" bibinfo.check output
          format.publisher.address output
        }
      if$
     }
  if$
      format.year "year" output.check
  new.block
  format.note output
  output.web.refs  % urlbst
  fin.entry
}

FUNCTION {techreport}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title
  "title" output.check
  new.block
  format.institution.address output
  format.year "year" output.check
  format.tr.number output.nonnull
  new.block
  format.note output
  output.web.refs  % urlbst
  fin.entry
}

FUNCTION {map}
{ output.bibitem
  format.cartographers "cartographer" output.check
  new.block
  format.title
  "title" output.check
  format.type "type" output.check
  new.block
  format.publisher.address output
  format.year "year" output.check
  new.block
  format.note output
  output.web.refs  % urlbst
  fin.entry
}

FUNCTION {patent}
{ output.bibitem
  format.inventors "inventor" output.check
  "; " *
  no.blank.or.punct
  format.assignees "assignee" output.check
  new.block
  format.title
  "title" output.check
  new.block
  format.tr.number output.nonnull
  format.journal.date "year" output.check
  new.block
  format.note output
  output.web.refs  % urlbst
  fin.entry
}

FUNCTION {unpublished}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  year empty$
    'skip$
    { format.year output }
  if$
  new.block
  format.note "note" output.check
  output.web.refs  % urlbst
  fin.entry
}

FUNCTION {default.type} { misc }

READ

FUNCTION {sortify}
{ purify$
  "l" change.case$
}

FUNCTION {chop.word}
{ 's :=
  'len :=
  s #1 len substring$ =
    { s len #1 + global.max$ substring$ }
    's
  if$
}

FUNCTION {format.lab.names}
{ 's :=
  s #1 "{vv~}{ll}" format.name$
  s num.names$ duplicate$
  #2 >
    { pop$ " et~al." * }
    { #2 <
        'skip$
        { s #2 "{ff }{vv }{ll}{ jj}" format.name$ "others" =
            { " et~al." * }
            { " and " * s #2 "{vv~}{ll}" format.name$ * }
          if$
        }
      if$
    }
  if$
}

FUNCTION {author.key.label}
{ author empty$
    { key empty$
        { cite$ #1 #3 substring$ }
        'key
      if$
    }
    { author format.lab.names }
  if$
}

FUNCTION {author.editor.key.label}
{ author empty$
    { editor empty$
        { key empty$
            { cite$ #1 #3 substring$ }
            'key
          if$
        }
        { editor format.lab.names }
      if$
    }
    { author format.lab.names }
  if$
}

FUNCTION {author.key.organization.label}
{ author empty$
    { key empty$
        { organization empty$
            { cite$ #1 #3 substring$ }
            { "The " #4 organization chop.word #3 text.prefix$ }
          if$
        }
        'key
      if$
    }
    { author format.lab.names }
  if$
}

FUNCTION {editor.key.organization.label}
{ editor empty$
    { key empty$
        { organization empty$
            { cite$ #1 #3 substring$ }
            { "The " #4 organization chop.word #3 text.prefix$ }
          if$
        }
        'key
      if$
    }
    { editor format.lab.names }
  if$
}

FUNCTION {calc.short.authors}
{ type$ "book" =
  type$ "inbook" =
  or
    'author.editor.key.label
    { type$ "proceedings" =
        'editor.key.organization.label
        { type$ "manual" =
            'author.key.organization.label
            'author.key.label
          if$
        }
      if$
    }
  if$
  'short.list :=
}

FUNCTION {calc.label}
{ calc.short.authors
  short.list
  "("
  *
  year duplicate$ empty$
  short.list key field.or.null = or
     { pop$ "" }
     'skip$
  if$
  *
  'label :=
}

INTEGERS { seq.num }

FUNCTION {init.seq}
{ #0 'seq.num :=}

EXECUTE {init.seq}

FUNCTION {int.to.fix}
{ "000000000" swap$ int.to.str$ *
  #-1 #10 substring$
}


FUNCTION {presort}
{ calc.label
  label sortify
  "    "
  *
  seq.num #1 + 'seq.num :=
  seq.num  int.to.fix
  'sort.label :=
  sort.label *
  #1 entry.max$ substring$
  'sort.key$ :=
}

ITERATE {presort}

SORT

STRINGS { longest.label last.label next.extra }

INTEGERS { longest.label.width last.extra.num number.label }

FUNCTION {initialize.longest.label}
{ "" 'longest.label :=
  #0 int.to.chr$ 'last.label :=
  "" 'next.extra :=
  #0 'longest.label.width :=
  #0 'last.extra.num :=
  #0 'number.label :=
}

FUNCTION {forward.pass}
{ last.label label =
    { last.extra.num #1 + 'last.extra.num :=
      last.extra.num int.to.chr$ 'extra.label :=
    }
    { "a" chr.to.int$ 'last.extra.num :=
      "" 'extra.label :=
      label 'last.label :=
    }
  if$
  number.label #1 + 'number.label :=
}

FUNCTION {reverse.pass}
{ next.extra "b" =
    { "a" 'extra.label := }
    'skip$
  if$
  extra.label 'next.extra :=
  extra.label
  duplicate$ empty$
    'skip$
    { "{\natexlab{" swap$ * "}}" * }
  if$
  'extra.label :=
  label extra.label * 'label :=
}

EXECUTE {initialize.longest.label}

ITERATE {forward.pass}

REVERSE {reverse.pass}

FUNCTION {bib.sort.order}
{ sort.label  'sort.key$ :=
}

ITERATE {bib.sort.order}

SORT

FUNCTION {begin.bib}
{ preamble$ empty$
    'skip$
    { preamble$ write$ newline$ }
  if$
  "\begin{thebibliography}{" number.label int.to.str$ * "}" *
  write$ newline$
  "\providecommand{\natexlab}[1]{#1}"
  write$ newline$
}

EXECUTE {begin.bib}

EXECUTE {init.config.constants}

EXECUTE {init.state.consts}

ITERATE {call.type$}

FUNCTION {end.bib}
{ newline$
  "\end{thebibliography}" write$ newline$
}

EXECUTE {end.bib}
