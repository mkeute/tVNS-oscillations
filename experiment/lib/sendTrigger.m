function iOObj = sendTrigger(port,iOObj,event)
% iOObj = sendTrigger(port,iOObj,event)
% port: 0: MCC DIO
% port: 1: parallel port 64bit matlab
% port: 2: parallel port 32bit matlab
% port: 3: NIDAQ DIO
% otherwise: virtual port (output in command window)
% How to use it:
% iOObj = sendTrigger(port);
% initializes the port object this object is needed for each call
% sendTrigger(port,iOObj,value)
% sends a value


if nargout == 0
    if port ==0 || port==3, %DIO
        putvalue(iOObj,event);
    elseif port ==1, % parallel port
        io64(iOObj,hex2dec('D030'),event);
    elseif port == 2 % parallel port
        io32(iOObj,hex2dec('D030'),event);
    else        
        if event~=0, 
            fprintf('VirtTrig: %i \n',event);
        end
    end
else
    if port ==0 || port==3, %DIO
        if port==0,
            iOObj = digitalio('mcc',0);
        else
            iOObj = digitalio('nidaq','Dev1');
        end
        addline(iOObj,0:7,'out');
    elseif port ==1,
        iOObj = io64();
        ioStatus = io64(iOObj);        
    elseif port ==2,
        iOObj = io32();
        ioStatus = io32(iOObj);
    else
        iOObj = [];
    end
end