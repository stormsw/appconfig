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
