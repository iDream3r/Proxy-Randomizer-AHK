#SingleInstance, Force

Gui, Launch:Font, Bold s14
Gui, Launch:Add, Text, Section, Proxy Randomizer

Gui, Launch:Font, norm s8
Gui, Launch:Add, Tab,x10 y40 w380 h150,&Proxy || &About

Gui, Launch:Add, Text, Section
Gui, Launch:Font, s10
Gui, Launch:Add, Text, Section y+5, Proxy list (txt file):
Gui, Launch:Add, Edit, ys x+m w165 vSelect
Gui, Launch:Add, Button, ys x+m w30 gBrowse, Browse
Gui, Launch:Add, Text, Section xs, Delay (s):
Gui, Launch:Add, Edit, ys x+m x+62 w85 vDelayer
Gui, Launch:Add, Text, Section xs, 
Gui, Launch:Add, Checkbox, ys xs x+109 vDelayRand, Randomize

Gui, Launch:Tab, 2
Gui, Launch:Font, s9
Gui, Launch:Add, Text, Section r1, How to use :`n`nYou can select a text file with all the proxy using "address":"port"`nformat and going back to the line for each proxy.`nThe script will select a random proxy in the text file.`nYou can also randomize the delay.`n`nPress CTRL+Q to quit, and press ESC to stop.
Gui, Launch:Font, s10

Gui, Launch:Tab
Gui, Launch:Add, Button, xm w80 gStart, Start
Gui, Launch:Add, Button, x+m w80 gStop, Stop
Gui, Launch:Add, Button, x+m w80 gReload, Reload
Gui, Launch:Add, Button, x+m w80 gExit, Exit
Gui, Launch:Add, StatusBar,, Current Proxy : None
Gui, Launch:Show,, ProxRand

Browse:
    if runner=1
    {
        FileSelectFile, SelectedFile, 3, , Open a file, Text Documents (*.txt; *.doc)
        GuiControl,,Select,%SelectedFile%
        return
    }

Start:
	Gui, Launch:Submit, NoHide
    Delayer := Delayer * 1000
    if runner = 1
    {
        if (Select="") or (Delayer="")
        {
            MsgBox, 64, Error, Please select a text file with the `nproxy list, and enter a delay.
            Status := 3
            return
        }
        global Switch := 0
        freader(Select)
        proxch(0, Delayer, DelayRand, prox, port, row)
        return
    }
    runner := 1
    return

freader(Select)
{
    FileRead, ProxFile, %Select%
    global prox := {}
    global port := {}
    global row := 0
    loop, read, %Select%
    {
        row := row + 1
        Linum = %A_Index%
        loop, parse, A_LoopReadLine, :,`r
        {
            if A_Index = 1
            {
                prox[Linum] := A_LoopField
            }
            else
            {
                port[Linum] := A_LoopField
            }
        }
    }
    Return
}

proxch(Status, Delayer, DelayRand, prox, port, row)
{
    Delay := Delayer
    if Status=  1
    {
        regwrite,REG_DWORD,HKCU,Software\Microsoft\Windows\CurrentVersion\Internet Settings,Proxyenable,0
        Proxy := "None"
    }
    if Status = 0
    {
        Random, Rand, 1, row
        fprox := prox[Rand]
        fport := port[Rand]
        regwrite,REG_DWORD,HKCU,Software\Microsoft\Windows\CurrentVersion\Internet Settings,Proxyenable,1
        regwrite,REG_SZ,HKCU,Software\Microsoft\Windows\CurrentVersion\Internet Settings,ProxyServer,%fprox%:%fport%
        Proxy = %fprox%:%fport%
    }
    SB_SetText("Current Proxy : " Proxy)
    if DelayRand = 1
    {
        Random, Rand, Round(Delayer/2, 1), Round(Delayer*1.5, 1)
        Delay = %Rand%
    }
    Sleep, Delay
    if Switch = 0
    {
        proxch(Status, Delayer, DelayRand, prox, port, row)
    }
    return
}

Stop:
    ESC::
    global Switch := 1
    proxch(1, Delayer, DelayRand, prox, port, row)
    return

Reload:
    Reload

Exit:
    ^q::
    ExitApp
