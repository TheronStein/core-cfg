---

## The Element Object

In the HTML DOM, the **Element object** represents an HTML element, like P, DIV, A, TABLE, or any other HTML element.

---

## Properties and Methods

The following properties and methods can be used on all HTML elements:

|Property / Method|Description|
|---|---|
|[accessKey](https://www.w3schools.com/jsref/prop_html_accesskey.asp)|Sets or returns the accesskey attribute of an element|
|[addEventListener()](https://www.w3schools.com/jsref/met_element_addeventlistener.asp)|Attaches an event handler to an element|
|[appendChild()](https://www.w3schools.com/jsref/met_node_appendchild.asp)|Adds (appends) a new child node to an element|
|[attributes](https://www.w3schools.com/jsref/prop_node_attributes.asp)|Returns a [NamedNodeMap](https://www.w3schools.com/jsref/dom_obj_attributes.asp) of an element's attributes|
|[blur()](https://www.w3schools.com/jsref/met_html_blur.asp)|Removes focus from an element|
|[childElementCount](https://www.w3schools.com/jsref/prop_element_childelementcount.asp)|Returns an elements's number of child elements|
|[childNodes](https://www.w3schools.com/jsref/prop_node_childnodes.asp)|Returns a [NodeList](https://www.w3schools.com/jsref/dom_obj_html_nodelist.asp) of an element's child nodes|
|[children](https://www.w3schools.com/jsref/prop_element_children.asp)|Returns an [HTMLCollection](https://www.w3schools.com/jsref/dom_obj_htmlcollection.asp) of an element's child elements|
|[classList](https://www.w3schools.com/jsref/prop_element_classlist.asp)|Returns the class name(s) of an element|
|[className](https://www.w3schools.com/jsref/prop_html_classname.asp)|Sets or returns the value of the class attribute of an element|
|[click()](https://www.w3schools.com/jsref/met_html_click.asp)|Simulates a mouse-click on an element|
|[clientHeight](https://www.w3schools.com/jsref/prop_element_clientheight.asp)|Returns the height of an element, including padding|
|[clientLeft](https://www.w3schools.com/jsref/prop_element_clientleft.asp)|Returns the width of the left border of an element|
|[clientTop](https://www.w3schools.com/jsref/prop_element_clienttop.asp)|Returns the width of the top border of an element|
|[clientWidth](https://www.w3schools.com/jsref/prop_element_clientwidth.asp)|Returns the width of an element, including padding|
|[cloneNode()](https://www.w3schools.com/jsref/met_node_clonenode.asp)|Clones an element|
|[closest()](https://www.w3schools.com/jsref/met_element_closest.asp)|Searches the DOM tree for the closest element that matches a CSS selector|
|[compareDocumentPosition()](https://www.w3schools.com/jsref/met_node_comparedocumentposition.asp)|Compares the document position of two elements|
|[contains()](https://www.w3schools.com/jsref/met_node_contains.asp)|Returns true if a node is a descendant of a node|
|[contentEditable](https://www.w3schools.com/jsref/prop_html_contenteditable.asp)|Sets or returns whether the content of an element is editable or not|
|[dir](https://www.w3schools.com/jsref/prop_html_dir.asp)|Sets or returns the value of the dir attribute of an element|
|[firstChild](https://www.w3schools.com/jsref/prop_node_firstchild.asp)|Returns the first child node of an element|
|[firstElementChild](https://www.w3schools.com/jsref/prop_element_firstelementchild.asp)|Returns the first child element of an element|
|[focus()](https://www.w3schools.com/jsref/met_html_focus.asp)|Gives focus to an element|
|[getAttribute()](https://www.w3schools.com/jsref/met_element_getattribute.asp)|Returns the value of an element's attribute|
|[getAttributeNode()](https://www.w3schools.com/jsref/met_element_getattributenode.asp)|Returns an attribute node|
|[getBoundingClientRect()](https://www.w3schools.com/jsref/met_element_getboundingclientrect.asp)|Returns the size of an element and its position relative to the viewport|
|[getElementsByClassName()](https://www.w3schools.com/jsref/met_element_getelementsbyclassname.asp)|Returns a collection of child elements with a given class name|
|[getElementsByTagName()](https://www.w3schools.com/jsref/met_element_getelementsbytagname.asp)|Returns a collection of child elements with a given tag name|
|[hasAttribute()](https://www.w3schools.com/jsref/met_element_hasattribute.asp)|Returns true if an element has a given attribute|
|[hasAttributes()](https://www.w3schools.com/jsref/met_node_hasattributes.asp)|Returns true if an element has any attributes|
|[hasChildNodes()](https://www.w3schools.com/jsref/met_node_haschildnodes.asp)|Returns true if an element has any child nodes|
|[id](https://www.w3schools.com/jsref/prop_html_id.asp)|Sets or returns the value of the id attribute of an element|
|[innerHTML](https://www.w3schools.com/jsref/prop_html_innerhtml.asp)|Sets or returns the content of an element|
|[innerText](https://www.w3schools.com/jsref/prop_node_innertext.asp)|Sets or returns the text content of a node and its descendants|
|[insertAdjacentElement()](https://www.w3schools.com/jsref/met_node_insertadjacentelement.asp)|Inserts a new HTML element at a position relative to an element|
|[insertAdjacentHTML()](https://www.w3schools.com/jsref/met_node_insertadjacenthtml.asp)|Inserts an HTML formatted text at a position relative to an element|
|[insertAdjacentText()](https://www.w3schools.com/jsref/met_node_insertadjacenttext.asp)|Inserts text into a position relative to an element|
|[insertBefore()](https://www.w3schools.com/jsref/met_node_insertbefore.asp)|Inserts a new child node before an existing child node|
|[isContentEditable](https://www.w3schools.com/jsref/prop_html_iscontenteditable.asp)|Returns true if an element's content is editable|
|[isDefaultNamespace()](https://www.w3schools.com/jsref/met_node_isdefaultnamespace.asp)|Returns true if a given namespaceURI is the default|
|[isEqualNode()](https://www.w3schools.com/jsref/met_node_isequalnode.asp)|Checks if two elements are equal|
|[isSameNode()](https://www.w3schools.com/jsref/met_node_issamenode.asp)|Checks if two elements are the same node|
|[isSupported()](https://www.w3schools.com/jsref/met_node_issupported.asp)|[Deprecated](https://www.w3schools.com/jsref/met_node_issupported.asp)|
|[lang](https://www.w3schools.com/jsref/prop_html_lang.asp)|Sets or returns the value of the lang attribute of an element|
|[lastChild](https://www.w3schools.com/jsref/prop_node_lastchild.asp)|Returns the last child node of an element|
|[lastElementChild](https://www.w3schools.com/jsref/prop_element_lastelementchild.asp)|Returns the last child element of an element|
|[matches()](https://www.w3schools.com/jsref/met_element_matches.asp)|Returns true if an element is matched by a given CSS selector|
|[namespaceURI](https://www.w3schools.com/jsref/prop_node_namespaceuri.asp)|Returns the namespace URI of an element|
|[nextSibling](https://www.w3schools.com/jsref/prop_node_nextsibling.asp)|Returns the next node at the same node tree level|
|[nextElementSibling](https://www.w3schools.com/jsref/prop_element_nextelementsibling.asp)|Returns the next element at the same node tree level|
|[nodeName](https://www.w3schools.com/jsref/prop_node_nodename.asp)|Returns the name of a node|
|[nodeType](https://www.w3schools.com/jsref/prop_node_nodetype.asp)|Returns the node type of a node|
|[nodeValue](https://www.w3schools.com/jsref/prop_node_nodevalue.asp)|Sets or returns the value of a node|
|[normalize()](https://www.w3schools.com/jsref/met_node_normalize.asp)|Joins adjacent text nodes and removes empty text nodes in an element|
|[offsetHeight](https://www.w3schools.com/jsref/prop_element_offsetheight.asp)|Returns the height of an element, including padding, border and scrollbar|
|[offsetWidth](https://www.w3schools.com/jsref/prop_element_offsetwidth.asp)|Returns the width of an element, including padding, border and scrollbar|
|[offsetLeft](https://www.w3schools.com/jsref/prop_element_offsetleft.asp)|Returns the horizontal offset position of an element|
|[offsetParent](https://www.w3schools.com/jsref/prop_element_offsetparent.asp)|Returns the offset container of an element|
|[offsetTop](https://www.w3schools.com/jsref/prop_element_offsettop.asp)|Returns the vertical offset position of an element|
|[outerHTML](https://www.w3schools.com/jsref/prop_html_outerhtml.asp)|Sets or returns the content of an element (including the start tag and the end tag)|
|[outerText](https://www.w3schools.com/jsref/prop_node_outertext.asp)|Sets or returns the outer text content of a node and its descendants|
|[ownerDocument](https://www.w3schools.com/jsref/prop_node_ownerdocument.asp)|Returns the root element (document object) for an element|
|[parentNode](https://www.w3schools.com/jsref/prop_node_parentnode.asp)|Returns the parent node of an element|
|[parentElement](https://www.w3schools.com/jsref/prop_node_parentelement.asp)|Returns the parent element node of an element|
|[previousSibling](https://www.w3schools.com/jsref/prop_node_previoussibling.asp)|Returns the previous node at the same node tree level|
|[previousElementSibling](https://www.w3schools.com/jsref/prop_element_previouselementsibling.asp)|Returns the previous element at the same node tree level|
|[querySelector()](https://www.w3schools.com/jsref/met_element_queryselector.asp)|Returns the first child element that matches a CSS selector(s)|
|[querySelectorAll()](https://www.w3schools.com/jsref/met_element_queryselectorall.asp)|Returns all child elements that matches a CSS selector(s)|
|[remove()](https://www.w3schools.com/jsref/met_element_remove.asp)|Removes an element from the DOM|
|[removeAttribute()](https://www.w3schools.com/jsref/met_element_removeattribute.asp)|Removes an attribute from an element|
|[removeAttributeNode()](https://www.w3schools.com/jsref/met_element_removeattributenode.asp)|Removes an attribute node, and returns the removed node|
|[removeChild()](https://www.w3schools.com/jsref/met_node_removechild.asp)|Removes a child node from an element|
|[removeEventListener()](https://www.w3schools.com/jsref/met_element_removeeventlistener.asp)|Removes an event handler that has been attached with the addEventListener() method|
|[replaceChild()](https://www.w3schools.com/jsref/met_node_replacechild.asp)|Replaces a child node in an element|
|[scrollHeight](https://www.w3schools.com/jsref/prop_element_scrollheight.asp)|Returns the entire height of an element, including padding|
|[scrollIntoView()](https://www.w3schools.com/jsref/met_element_scrollintoview.asp)|Scrolls the an element into the visible area of the browser window|
|[scrollLeft](https://www.w3schools.com/jsref/prop_element_scrollleft.asp)|Sets or returns the number of pixels an element's content is scrolled horizontally|
|[scrollTop](https://www.w3schools.com/jsref/prop_element_scrolltop.asp)|Sets or returns the number of pixels an element's content is scrolled vertically|
|[scrollWidth](https://www.w3schools.com/jsref/prop_element_scrollwidth.asp)|Returns the entire width of an element, including padding|
|[setAttribute()](https://www.w3schools.com/jsref/met_element_setattribute.asp)|Sets or changes an attribute's value|
|[setAttributeNode()](https://www.w3schools.com/jsref/met_element_setattributenode.asp)|Sets or changes an attribute node|
|[style](https://www.w3schools.com/jsref/prop_html_style.asp)|Sets or returns the value of the style attribute of an element|
|[tabIndex](https://www.w3schools.com/jsref/prop_html_tabindex.asp)|Sets or returns the value of the tabindex attribute of an element|
|[tagName](https://www.w3schools.com/jsref/prop_element_tagname.asp)|Returns the tag name of an element|
|[textContent](https://www.w3schools.com/jsref/prop_node_textcontent.asp)|Sets or returns the textual content of a node and its descendants|
|[title](https://www.w3schools.com/jsref/prop_html_title.asp)|Sets or returns the value of the title attribute of an element|
|toString()|Converts an element to a string|

#JavaScript/HTML
#Documentation
#Webdev
#JavaScript/Reference
#HTML/Reference