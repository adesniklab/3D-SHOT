function waitfornidaq
%% waitfornidaq checks to see if the last acquisition sweep has ended, then calls 'acquire' if so
% stops the nidaq from shitting its pants if you run the timer too fast
global ExpStruct Exp_Defaults globalTimer

IAN_SOLUTION=0;


% contah = 0
% while not s.IsDone
%     pause(0.1);
%     contah = contah+1
% end
%
% if not(s.IsRunning|s.IsDone|s.IsLogging)
%     acquire
% else
%     while s.IsDone==0
%         'blerg'
%         tic
%         s.wait(5)
%         toc
%     end
%
%     if s.IsDone==1
%         'yay'
%     acquire
%     else
%     'something got fucked up'
%     end
%
% end

%readyTorun gets set to 0 at the start of acquisition, and reset to 1 at
%the end of the acquisition sweep. if it isn't 1, you really should not try
%to start the nidaq yet

%% Ian's solution to handlign timing problems
persistent ACQ_TIMER skipCount

if IAN_SOLUTION
    availTime = Exp_Defaults.ISI - Exp_Defaults.sweepduration;
    if isempty(skipCount) || ~exist('skipCount','var')
        skipCount=0;
    end
    
    a=tic;
    delayedTime=0;
    while ~ExpStruct.readyTorun
        %disp('Delayed Start...')
        %delayedTime
        pause(0.1);
        delayedTime =toc(a);
%          skipCount
%          if skipCount>2;
%              disp('skippend to many gonna try...')
%              skipCount=0;
%              ExpStruct.readyTorun=1;
%              return
% %             disp('Nuclear Option Killing timer...')
% %             stop(globalTimer);
% %             globalTimer=timer('TimerFcn', 'waitfornidaq', 'TaskstoExecute', Exp_Defaults.total_sweeps, 'Period',Exp_Defaults.ISI, 'ExecutionMode','fixedRate');
% %             skipCount = 0;
% %             %start(globalTimer);
% %             return;
%          end 
        
        if delayedTime > availTime
            disp('Delayed too Long skipping this trial, good luck')
            ExpStruct.readyTorun=1;
             skipCount=skipCount+1;
            pause(2); %give extra time to finish
            return; %return early and see what happens
        end
    end
%     if delayedTime >1;
%         %disp(['Delayed ' num2str(delayedTime) ' seconds']);
%         disp('extrasecond');
%         pause(1)
%     end
    
    if ExpStruct.readyTorun;
        if ~exist('ACQ_TIMER','var') || isempty(ACQ_TIMER)
            ACQ_TIMER=tic;
        else
            disp(['Time since last Acquire: ' num2str(toc(ACQ_TIMER)) ' seconds']);
        end
        acquire
        ACQ_TIMER=tic;
         skipCount=0;
    else
        disp('Timer stuff STILL junked! reset try again')
        pause(2)
        
        ExpStruct.readyTorun=1;
    end
    return
    
end
%% Alex's Solution w/ian ACQ_timer

if ExpStruct.readyTorun
        if ~exist('ACQ_TIMER','var') || isempty(ACQ_TIMER)
            ACQ_TIMER=tic;
        else
            disp(['Time since last Acquire: ' num2str(toc(ACQ_TIMER)) ' seconds']);
        end
        acquire
        ACQ_TIMER=tic;
else
    disp('warning: timer stuff is junked up, ISI probably too short');
    pause(2)
    
    ExpStruct.readyTorun=1;
    disp('okay try it now');
    
end