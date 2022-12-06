-module(connectionBufferForRemoteWorker).

-export([getWorkFromRemoteServer/0,createConnectionWithServer/0]).

getWorkFromRemoteServer()->
    server ! {givetask,self()},
     receive
         {dotask,N}-> 
          N
    end.
 
 createConnectionWithServer()->
    receive
		{WorkerAddress}-> 
         N=getWorkFromRemoteServer(),
         WorkerAddress ! {N},
         createConnectionWithServer();
      {Bitcoin,RandomString}->
        sendserver ! {Bitcoin,RandomString},
        createConnectionWithServer()
   end.