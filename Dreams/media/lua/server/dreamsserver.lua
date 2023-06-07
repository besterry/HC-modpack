Dreams = {}
Dreams.version = "1.23";
Dreams.author = "Nebula & Star";
Dreams.modName = "Dreams";

Dreams.OnClientCommand = function(module, command, player, args)
	if not isServer() then return end
	if module ~= "Dreams" then return end; 
	
 	if command == "Say" then       
		player:Say(args.saythis);
	end
	
end
	
Events.OnClientCommand.Add(Dreams.OnClientCommand);
