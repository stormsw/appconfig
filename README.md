# App.config tool

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

filename = 'app.config'

doc = Nokogiri::XML(File.open(filename)) do |config|
# NOBLANKS - Remove blank nodes
# NOENT - Substitute entities
# NOERROR - Suppress error reports
# STRICT - Strict parsing; raise an error when parsing malformed documents
# NONET - Prevent any network connections during parsing. Recommended for parsing untrusted documents.
  config.strict.nonet
end

#print doc.to_s
#wizards = doc.css("Wizards wizard")
wizards = doc.xpath('//wizard')
puts "Found #{wizards.count}'s wizards sections document wide."

editors_names_usage = Hash.new { |h, k| h[k] = 0 }
editors = doc.xpath('//editor')

puts "Found #{editors.count}'s editors sections document wide."

editors.each do |editor|
#  puts editor.attributes.inspect
#  exit
  clear_name = editor[:name].split(':').first
  editors_names_usage[clear_name] += 1
end

puts editors_names_usage.inspect

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
