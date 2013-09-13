# App.config tool

Configuration tool uses Thor to cope with command line parameters

## Usage
It assumed you have ruby with ruby gems installed
You required to install thor and nokogiri gem

```
gem install nokogiri
gem install thor
```

### Commands
You can get help using this tool w/o params or get extended help on each command issuing
```
ruby appconfig.rb help <command>
```

#### Info
Command gives statistics from specified config

```
appconfig info <filename>
```

#### Stages
List configured stages for <transaction code> from <filename>

```
  appconfig.rb stages <filename> <transaction code> [options]

Options:
  -d, [--show-dups]     # Verbose output of XML block when given stage already parsed.
  -e, [--show-editors]  # Print editors for each stage.
  -m, [--show-meta]     # Print wizard configuration meta.
  -v, [--verbose]       
```

#### Normalize stages
This option will put separate wizard configuration for each transaction

Each wizard contains _assembly_, _stages_ and _meta_ attributes.
Attribute _stages_ may contains <csv:stage>.
Attribute _meta_ consists of 2 part separated by ';'. <metacode>;<csv:transactionCode>
The <metacode> follows (all|\d+) regex rule [i.e "all" or number].The <csv:transactionCode> can be (all|([\S]+[\S\d]*[,]*)+) regex [i.e. all or alpha-digital coma-separated words] 
If transaction type fits this (meta=<metacode> or <metcode> is 'all') then it will check transaction code against the list of <csv:transactionCode>
When it matches (ignore-case) to some element value we assumes that stage suits us.


# MD format how-to
# This is an H1
## This is an H2
...
###### This is an H6

Each paragraph begins on a new line. Simply press <return> for a new line.
 
For example,  
like this.
 
You'll need an empty line between a paragraph and any following markdown construct, such as an ordered or unordered list, for that to be rendered. Like this:
 
* Item 1
* Item 2


*Italic characters* 
_Italic characters_
**bold characters**
__bold characters__


* Item 1
* Item 2
* Item 3
    * Item 3a
    * Item 3b
    * Item 3c
	
	
1. Step 1
2. Step 2
3. Step 3
    a. Step 3a
    b. Step 3b
    c. Step 3c
	

1. Step 1
2. Step 2
3. Step 3
    * Item 3a
    * Item 3b
    * Item 3c

	
Introducing my quote:
  
> Neque porro quisquam est qui 
> dolorem ipsum quia dolor sit amet, 
> consectetur, adipisci velit...


Use the backtick to refer to a `function()`.
  
There is a literal ``backtick (`)`` here.


Indent every line of the block by at least 4 spaces or 1 tab. Alternatively, you can also use 3 backtick quote marks before and after the block, like this:
 
``` 
Text to appear as a code block.
``` 
 
Within a code block, ampersands (&) and angle brackets (< and >)are automatically converted into HTML entities.
 
This is a normal paragraph:
    This is a code block.
    With multiple lines.
	

	
This is [an example](http://www.slate.com/ "Title") inline link.
 
[This link](http://example.net/) has no title attribute.

This is a regular paragraph.
 
<table>
    <tr>
        <td>Foo</td>
    </tr>
</table>
 
This is another regular paragraph.
