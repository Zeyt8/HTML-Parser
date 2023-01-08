# HTML Parser - Formal Languages and Automata

I have chosen to complete this assignment using FLEX in C++.

I have created 2 classes.

The Tag class represents an HTML tag. This tag contains a name, a vector of child tags, and a vector of style tags. It also includes a toString function to display the tag in different ways as needed. The StyleTag class only contains a name.

The \<br> and \<b> tags are completely ignored.

## Body tags

When I encounter the \<body> tag, I enter the IN_BODY state. When I find a \<div> tag, I will enter the IN_DIV state and push it, for any other tag I enter the IN_TAG state and push it. I determine if I have found a tag by checking for the form \<tag followed by either > or a space.

When the closing tag is found (i.e. a sequence of the form \</tag>), I pop the state.

I add the tag to the list of sub-tags in the body tag. If the tag is a div type, I add it to the list of div tags and update last_div as the last index in the div list.

Image and input tags do not enter the IN_TAG state, as they cannot contain sub-tags.

If after the name of the tag there is a space and not a >, then after entering the IN_DIV or IN_TAG state, I will also push to the IN_INLINE_STYLE state, which is detailed below.

## Div tags

I have detailed above when I enter the DIV state.

There is one exception. If I find a closing \</div> tag and I am in the IN_DIV state, in addition to the pop, I will also decrease last_div by 1. This allows me to add sub-tags to the appropriate div in case there is a div within a div.

Processing the found tags is done exactly as above, but without adding the tags to the list of those in the body, but rather as sub-tags of the div tag at the position last_div.

## Style tags

When I encounter the sequence \<style> I enter the IN_STYLE state.

In this state, to identify a style tag I look for a sequence of characters followed by a space and {. I add the tag to style_head_tags.

I look for sequences of the form characters followed by : and other characters and ; at the end. When I find one, I add a StyleTag to the last tag in style_head_tags.

I exit the state when I encounter the sequence \</style>.

## Inline style

When I find a div or body tag, if after the name of the tag there is a space and not a >, then after entering the IN_DIV or IN_TAG state, I will also push to the IN_INLINE_STYLE state. I add the tag to style_head_tags.

Here I look for a sequence of characters followed by ="otherCharacters". I add the tag to the list of style tags of the last tag in style_head_tags.

When I encounter > I pop the state.

## In tag

The IN_TAG state is used to only take the first level tags from the body.

In the IN_TAG state I verify similarly to IN_BODY, but only for div or for tags with inline style, as the others do not bring any changes to the final result.

## Main

I print the tag lists according to the requirements.