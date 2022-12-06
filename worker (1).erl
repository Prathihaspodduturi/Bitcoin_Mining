-module(worker).

-export([startWorkerProcess/1 , generateRandomString/0 , form/2, getWorkFromServer/0 , startMining/4
,getWorkFromRemoteServer/0,createConnectionWithServer/0,spawnWorkerProcess/3]).


spawnWorkerProcess(N,Hostname,PID)->
   if
      N==0 ->
         ok;
      true ->
         if
            Hostname==""->
               spawn(worker,getWorkFromServer , []),
               spawnWorkerProcess(N-1,Hostname,PID);
            true ->
               PID ! {self()},
               receive
                  {NumberOfZeros}->  
                  F=form("0",NumberOfZeros-1),
                  spawn(worker,startMining,[0,NumberOfZeros,F,PID]),
                  spawnWorkerProcess(N-1,Hostname,PID)
               end 
         end
   end.

startWorkerProcess(N)->
   {ok, ServerLoc} = io:read("Is server present in remote location enter 1 for yes and 0 for no "),
   if
      ServerLoc==1 ->
         {ok,Hostname}=io:read("Enter address of remote node on which is server is running "),
         PID=spawn(Hostname,connectionBufferForRemoteWorker,createConnectionWithServer,[]),
         spawn(worker,spawnWorkerProcess,[N,Hostname,PID]);
      true ->
         spawnWorkerProcess(N,"","")
   end.






generateRandomString()->
    Z=base64:encode(crypto:strong_rand_bytes(8)),
    A=string:concat("v.putagumpalla",binary_to_list(Z)),
    A.

form(S,0)->
    S;
form(S,N)->
   form(S++"0",N-1).

getWorkFromServer()->
	server ! {givetask,self()},
	receive
		{dotask,N}-> 
         F=form("0",N-1),
         startMining(1,N,F,"")
   end.

     

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


startMining(Counter,N,F,PID)->
	RandomString = generateRandomString(),
	Bitcoin=lists:flatten(io_lib:format("~64.16.0b",
   [binary:decode_unsigned(crypto:hash(sha256,RandomString))])),
	Y=lists:sublist(Bitcoin,N),
   if
		F==Y->
            if
               PID=="" ->
                  sendserver ! {Bitcoin,RandomString}; 
               true ->
                  PID !{Bitcoin,RandomString}
            end,
            if
              Counter==200->
						ok;
				  true->
               startMining(Counter+1,N,F,PID)
            end;
       true->
         startMining(Counter,N,F,PID)
   end.

          
		  
        