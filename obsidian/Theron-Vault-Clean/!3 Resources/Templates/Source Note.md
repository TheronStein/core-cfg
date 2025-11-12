```js
---
cssclasses:
  - list-cards
  - cards 
  - cards-cols-3
template-version: "5.0.0"
note-type: source_note
aliases: []
creation date: <% tp.file.creation_date() %>
modification date: <% tp.file.last_modified_date("dddd Do MMMM YYYY HH:mm:ss") -%>

<%*
let target = ""
let suggestionlist =["harrison","cecile","Robins","Catzung","article ","case-files","bates","Lawrence","Learning clinical reasoning", "Schwartz" , "Kaplan" , "Novel" ,"Goldberg" ,"Derm book thingy","UpToDate","Apley ortho","Handbook_of_fracturs","other"];
let flag =  await tp.system.suggester(suggestionlist,suggestionlist)
tR+= "\nbook-name: " + flag
let defaultuse="true"
defaultuse = await tp.system.suggester(["Yes", "No"], ["true", "false"],true ,"would you like to use the default naming scheme for the PDF?")
let namefile=" "
if (defaultuse =="true")
{
	switch (flag)
	{
		case "Derm book thingy":
			let chap=await tp.system.prompt("what is the chapter number", "")
			let thing = await tp.system.suggester(["Big", "little"], ["true", "false"],true ,"big book or little book?")
			if (thing=="true")
			{
				namefile="iMD - Dermatology - Fifth Edition - " + chap+". "+ tp.file.title + ".pdf"
			}
			else
			{
				namefile="iMD - Lookingbill and Marks' Principles of Dermatology - Sixth Edition - " + chap+". "+ tp.file.title + ".pdf"
			}	
			tR += "\nannotation-target: " + namefile 
			tR+="\npage-count: "+ await tp.system.prompt("how many pages?", " ")
			break;
		case "UpToDate":
			namefile="iMD - Uptodate - " + tp.file.title +".pdf"
			tR += "\nannotation-target: " + namefile 
			tR+="\npage-count: "+ await tp.system.prompt("how many pages?", " ")
			break;
		case "Apley ortho":
			let chap2=await tp.system.prompt("what is the chapter number", "")
			namefile="Apley_" + chap+" "+ tp.file.title + ".pdf"
			tR += "\nannotation-target: " + namefile 
			tR+="\npage-count: "+ await tp.system.prompt("how many pages?", " ")
			break;
		case "Handbook_of_fracturs":
			namefile= "Handbook_of_fracturs_" + tp.file.title + ".pdf"
			tR += "\nannotation-target: " + namefile 
			tR+="\npage-count: "+ await tp.system.prompt("how many pages?", " ")
			break;
		case "web":
			target = await tp.system.prompt("Enter the URL of the source", "")
			tR += "\nannotation-target: " + target + "\nannotation-target-type: web"
			break;
		default: 
			namefile = tp.file.title + ".pdf"
	}
}
else 
{
	let namefile1 = await tp.system.prompt("what is the name of the source", "")
	switch (flag)
	{
		case "Derm book thingy":
			let chap=await tp.system.prompt("what is the chapter number", "")
			let thing = await tp.system.suggester(["Big", "little"], ["true", "false"],true ,"big book or little book?")
			if (thing=="true")
			{
				namefile="iMD - Dermatology - Fifth Edition - " + chap+". "+ namefile1 + ".pdf"
			}
			else
			{
				namefile="iMD - Lookingbill and Marks' Principles of Dermatology - Sixth Edition - " + chap+". "+ namefile1 + ".pdf"
			}	
			tR += "\nannotation-target: " + namefile 
			tR+="\npage-count: "+ await tp.system.prompt("how many pages?", " ")
			break;
		case "UpToDate":
			namefile="iMD - Uptodate - " + namefile1 +".pdf"
			tR += "\nannotation-target: " + namefile 
			tR+="\npage-count: "+ await tp.system.prompt("how many pages?", " ")
			break;
		case "Apley ortho":
			let chap2=await tp.system.prompt("what is the chapter number", "")
			namefile="Apley_" + chap+" "+namefile1 + ".pdf"
			tR += "\nannotation-target: " + namefile 
			tR+="\npage-count: "+ await tp.system.prompt("how many pages?", " ")
			break;
		case "Handbook_of_fracturs":
			namefile= "Handbook_of_fracturs_" + namefile1+ ".pdf"
			tR += "\nannotation-target: " + namefile 
			tR+="\npage-count: "+ await tp.system.prompt("how many pages?", " ")
			break;
		case "web":
			target = await tp.system.prompt("Enter the URL of the source", "")
			tR += "\nannotation-target: " + target + "\nannotation-target-type: web"
			break;
		default: 
			namefile = namefile1 + ".pdf"
	}
}
tR+="\n"
-%>
<%*  
let exec1 = "true"  
while (exec1=="true")  
{  
	exec1 = await tp.system.suggester(["Yes", "No"], ["true", "false"],false ,"do you want to change the initial status of this source?(read, broken down or linked up)")  
	if (exec1=="true")  
	{  
		read = await tp.system.suggester(["Yes", "No"], ["true", "false"],false ,"have you already read this source?")
		tR+= "read: " + read + "\n"
		broken = await tp.system.suggester(["Yes", "No"], ["true", "false"],false ,"have you already broken down this sourcce?")
		tR+= "broken-down: " + broken + "\n"
		exec1 = "false"
	}  
	else 
	{  
		tR+= "read: false\nbroken-down: false\n"
	}  
}  
-%>
```