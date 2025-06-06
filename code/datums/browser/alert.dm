/datum/browser/modal/alert/New(User,Message,Title,Button1="Ok",Button2,Button3,StealFocus = 1,Timeout=6000)
	if (!User)
		return

	var/output = {"<center><b>[Message]</b></center><br />
		<div style="text-align:center">
		<a style="font-size:large;float:[( Button2 ? "left" : "right" )]" href='byond://?src=[REF(src)];button=1'>[Button1]</a>"}

	if (Button2)
		output += {"<a style="font-size:large;[( Button3 ? "" : "float:right" )]" href='byond://?src=[REF(src)];button=2'>[Button2]</a>"}

	if (Button3)
		output += {"<a style="font-size:large;float:right" href='byond://?src=[REF(src)];button=3'>[Button3]</a>"}

	output += {"</div>"}

	..(User, ckey("[User]-[Message]-[Title]-[world.time]-[rand(1,10000)]"), Title, 350, 150, src, StealFocus, Timeout)
	set_content(output)

/datum/browser/modal/alert/Topic(href,href_list)
	if (href_list["close"] || !user || !user.client)
		opentime = 0
		return
	if (href_list["button"])
		var/button = text2num(href_list["button"])
		if (button <= 3 && button >= 1)
			selectedbutton = button
	opentime = 0
	close()

/**
 * **DEPRECATED: USE tgui_alert(...) INSTEAD**
 *
 * Designed as a drop in replacement for alert(); functions the same. (outside of needing User specified)
 * Arguments:
 * * User - The user to show the alert to.
 * * Message - The textual body of the alert.
 * * Title - The title of the alert's window.
 * * Button1 - The first button option.
 * * Button2 - The second button option.
 * * Button3 - The third button option.
 * * StealFocus - Boolean operator controlling if the alert will steal the user's window focus.
 * * Timeout - The timeout of the window, after which no responses will be valid.
 */
/proc/tgalert(mob/User, Message, Title, Button1="Ok", Button2, Button3, StealFocus = TRUE, Timeout = 6000)
	if (!User)
		User = usr
	switch(askuser(User, Message, Title, Button1, Button2, Button3, StealFocus, Timeout))
		if (1)
			return Button1
		if (2)
			return Button2
		if (3)
			return Button3

//Same shit, but it returns the button number, could at some point support unlimited button amounts.
/proc/askuser(mob/User,Message, Title, Button1="Ok", Button2, Button3, StealFocus = 1, Timeout = 6000)
	if (!istype(User))
		if (istype(User, /client/))
			var/client/C = User
			User = C.mob
		else
			return
	var/datum/browser/modal/alert/A = new(User, Message, Title, Button1, Button2, Button3, StealFocus, Timeout)
	A.open()
	A.wait()
	if (A.selectedbutton)
		return A.selectedbutton
