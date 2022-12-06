-module(server_file).

-export([startServer/0 , assignTask/1, mine/2, printBitCoinFromWorker/0]).

startServer()->
   statistics(runtime),
   statistics(wall_clock),
   {ok, N} = io:read("Enter required number of leading 0s in bitcoin: "),
	register(server,spawn(server_file,assignTask,[N])),
   register(sendserver,spawn(server_file,printBitCoinFromWorker,[])),
   spawn(server_file,mine,[N,0]).

printBitCoinFromWorker()->
	receive
		{Bitcoin,RandomString}->
         io:format("~s~n",[RandomString++" "++Bitcoin]),
         printBitCoinFromWorker()
   end.
assignTask(N)->
	receive
		{givetask,Id}->
			Id ! {dotask,N},
      assignTask(N)
   end.

mine(N,Counter)->
    Randomstring = worker:generateRandomString(),
    Bitcoin=lists:flatten(io_lib:format("~64.16.0b",
    [binary:decode_unsigned(crypto:hash(sha256,Randomstring))])),
    Y=lists:sublist(Bitcoin,N),
    F=worker:form("0",N-1),
    if
      F==Y->
			% io:format("~s~n",[Randomstring++" "++Bitcoin]),
			if
             Counter==1000->
               {_, Time1} = statistics(runtime),
               {_, Time2} = statistics(wall_clock),
               U1 = Time1,
               U2 = Time2,
               io:format("CPU TIME=~p microseconds~n",
               [U1]),
               io:format("REAL TIME=~p microseconds~n",
               [U2]),
               io:format("Ratio of CPU to REAL TIME is ~p",[U1/U2]);
				  true->
                mine(N,Counter+1)
         end;
      true->
         mine(N,Counter)
    end.
   
   



