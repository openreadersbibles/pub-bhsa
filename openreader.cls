% First identify the class:
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{openreader}

\LoadClass{article}

\RequirePackage{etoolbox}

% Define custom options
\newif\ifgreek
\newif\ifhebrew
\newif\ifltr
\newif\ifrtl

\greekfalse
\hebrewfalse

\RequirePackage{polyglossia}
\def\textmainlanguage#1{\csname text\mainlanguagename\endcsname{#1}}
\def\selectmainlanguage{\selectlanguage{\mainlanguagename}}

\RequirePackage{titlesec}
% make sections (here, chapters) nice inline deals
\titleformat{\section}[runin]{\selectmainlanguage\bfseries}{}{}{}

\RequirePackage{fontspec}
\RequirePackage[top=2cm,bottom=2cm,left=2cm,right=2cm]{geometry}


\RequirePackage{fancyhdr}
\fancypagestyle{plain}{
  \fancyhf{} % Clear all header and footer fields
  \fancyfoot[C]{\selectmainlanguage\thepage} % Footer with page number in the center
  \renewcommand{\headrulewidth}{0pt} % Remove header rule
  \renewcommand{\footrulewidth}{0pt} % Remove footer rule
}
\pagestyle{plain} % Apply the custom footer to all pages

\makeatletter
\renewcommand{\maketitle}{
  \begin{center}
    {\LARGE \@title \par}
  \end{center}
}
\makeatother

\def\FootnoteSubHeader#1{\textsuperscript{\selectmainlanguage #1}}
\def\FootnoteSubFooter{.\ }

% Print a verse marker in the main verse. The two arguments are chapter and verse
\def\MainTextVerseMark#1#2{%
  \ifnum#2=1
    % Don't print a verse marker, because there is already a chapter marker
  \else
    \textsuperscript{\selectmainlanguage\localnumeral{#2}}%
\fi}

% \def\VerseMarker#1{\textsuperscript{\selectmainlanguage #1}~}


% This is the footnote marker that goes over a word that is glossed or parsed.
\def\MainTextFootnoteMark#1{\textsuperscript{\selectmainlanguage #1}}

\def\Gloss#1{\textmainlanguage{\textit{#1}}}
\def\Parse#1{\textmainlanguage{#1}}
\def\FnParse#1{\Parse{#1}}

\let\Footnotesize=\footnotesize  % save the definition
\let\footnotesize=\large  % make a footnotesize change very visible

% this is the width of the hanging indent
\newdimen\FootnoteHangingIndent
\FootnoteHangingIndent=20pt

% maximum height of footnotes
\newdimen\FootnoteSectionHeight
\FootnoteSectionHeight=9in

\raggedbottom
\addtolength{\topskip}{0pt plus 10pt}

\def\VerseRef#1{\selectmainlanguage  #1\quad}

\newdimen\FootnoteTextSize
\newdimen\FootnoteBaselineSkip
\FootnoteTextSize=12pt
\FootnoteBaselineSkip=14pt

\ExplSyntaxOn
\NewExpandableDocumentCommand \langdir { m }
  {
    \prop_item:No \l_xpg_langsetup_prop { #1 / direction }
  }
\ExplSyntaxOff

\def\DefineLanguageDirection{%
\typeout{DefineLanguageDirection running.}
\typeout{\mainlanguagename}
\typeout{\langdir{\mainlanguagename}}
\typeout{\langdir{persian}}
}

\def\FnFormGloss#1#2{%
    \ifgreek
        \textgreek{#1}
    \else
        \ifhebrew
            \texthebrew{#1}
        \fi
    \fi 
    \Gloss{#2}}
\def\FnParseFormGloss#1#2#3{%
    \Parse{#1} 
    \ifgreek
        \textgreek{#2}
    \else
        \ifhebrew
            \texthebrew{#2}
        \fi
    \fi 
    \Gloss{#3}}
% This will of course always be Hebrew.
\def\KetivMarker{\texthebrew{כת֗}}
\def\QereMarker{\texthebrew{ק֗}}
\def\FnKetivQere#1#2{\KetivMarker \texthebrew{#1} \QereMarker \texthebrew{#2}\ }

\def\FnFreeform#1{\Gloss{#1}}


% \VerseFootnote creates the footnote that is associated with a verse. (It does not place a marker in the text.)
% The first argument is the verse number; the second argument is the footnote text.
\def\VerseFootnote#1#2{\FootnoteWithMarker{\VerseRef{\selectmainlanguage #1}}{#2}}    

% \FootnoteHeader creates a chapter header in the footnotes. The argument is the chapter title (e.g., Chapter 1).
\def\FootnoteHeader#1{\ \FootnoteWithoutMarker{\selectmainlanguage\bf #1}\ }


\AtBeginDocument{%

% Set the ifs for Greek and Hebrew
\iflanguageloaded{greek}{\greektrue}{\greekfalse}
\iflanguageloaded{hebrew}{\hebrewtrue}{\hebrewfalse}


\global\edef\MainLanguageDirection{\langdir{\mainlanguagename}}

% Check the value of \MainLanguageDirection and set \ifrtl accordingly
\def\RL{RL}
\ifx\MainLanguageDirection\RL
  \global\rtltrue
  \global\ltrfalse
  \typeout{RTL is true. LTR is false.}
\else
  \global\rtlfalse
  \global\ltrtrue
  \typeout{LTR is true. RTL is false.}
\fi

}


\makeatletter

\long\def\FootnoteWithMarker#1#2{\insert\footins{%
    \ifrtl
        \@RTLtrue%
    \else
        \@RTLfalse%
    \fi
    \reset@font%
    \interlinepenalty\interfootnotelinepenalty
    \splittopskip\footnotesep
    \splitmaxdepth \dp\strutbox \floatingpenalty \@MM
    \hsize\columnwidth \@parboxrestore
    \leavevmode
    \color@begingroup
    \fontsize{12pt}{14pt}\selectfont
    \hbox to \FootnoteHangingIndent{#1\hfil}\hangindent=\FootnoteHangingIndent \hangafter=1 #2
    \color@endgroup}}%

\long\def\FootnoteWithoutMarker#1{\insert\footins{%
    \ifrtl
        \@RTLtrue%
    \else
        \@RTLfalse%
    \fi
    \reset@font%
    \interlinepenalty\interfootnotelinepenalty
    \splittopskip\footnotesep
    \splitmaxdepth \dp\strutbox \floatingpenalty \@MM
    \hsize\columnwidth \@parboxrestore
    \color@begingroup
    \fontsize{12pt}{14pt}\selectfont
    \medskip
    \bf #1
    \smallskip
    \color@endgroup}}%

\makeatother


\endinput