// The javascript API is produced by the following command
// openapi generate -i webapi.openapi.yaml -g javascript --additional-properties=usePromises=true -o /tmp/js

// This program is called this way (if your javascript is in your home/JS)
// export npm_config_prefix=$HOME/JS
// export NODE_PATH=$HOME/JS/lib/node_modules
// WEBAPIPASS=your_password node demo.js --server_url http://your_bolixo_server.org --email your_email

var Webapi = require('bolixo_webapi');

function usage(){
	console.log ("Options are:\n");
	console.log ("\t--server_url http[s]://server_url");
	console.log ("\t--email email-for-the-account");
	console.log ("\t--password password");
	console.log ("\t  The password may be passed instead using the WEBAPIPASS environment variable");
	process.exit (1);
}

var server_url = null;
var email = null;
var pass = process.env.WEBAPIPASS;
var sessionid="empty";
var groups = null;
// Process arguments
for (var i=2; i<process.argv.length; i++){
	var arg = process.argv[i];
	if (i < process.argv.length-1){
		var next = process.argv[i+1];
		if (arg === "--server_url"){
			server_url = next;
		}else if (arg === "--email"){
			email = next;
		}else if (arg === "--password"){
			pass = next;
		}else{
			console.log ("Invalid argument: "+arg);
			usage();
		}
		i++;
	}
}
if (server_url === null || email === null || pass === null){
	console.log ("Options --server_url, --email and --password are all mandatory\n");
	usage();
};

// API functions
var api = new Webapi.DefaultApi();
api.apiClient.basePath=server_url;
console.log (api.apiClient);
function show_proto (name,data){
	console.log("---- "+name);
	console.log(data);
	console.log ("-----");
}
function call(func){
	return function(error,data,response){
		if (error) {
			console.error(error);
		} else {
			func(data);
		}
	}
}
		

function do_logout(){
	var data = new Webapi.Logout();
	data.sessionid = sessionid;
	api.logout(data).then(function(data){
			console.log ("logout done");
		},function(error){
			console.log(error);
		});
}
async function do_login(user,password){
	var data = new Webapi.Login();
	data.email = user;
	data.password = password;
	console.log (data);
	await api.login(data).then(function(data){
			console.log (data);
			if (data.success){
				sessionid = data.sessionid;
			}
		}, function(error){
			console.log(error);
		});
}
// Method to get the news feed for the current user
async function do_interest_check (owner,fulltext,offset,nb,firstseen){
	var data = new Webapi.InterestCheck();
	data.sessionid = sessionid;
	data.owner = owner;
	data.fulltext = fulltext;
	data.offset = offset;
	data.nb = nb;
	data.firstseen = firstseen;
	await api.interestCheck(data).then(function(data){
			console.log (data);
		},function(error){
			console.log(error);
		});
}
// Method to get the list of groups this user belongs
// inbox (private messages) is presented as a group
async function do_list_groups(owner,only_owner){
	var data = new Webapi.ListGroups();
	data.sessionid = sessionid;
	data.owner = owner;
	data.only_owner = only_owner;
	await api.listGroups(data).then(function(data){
			groups = data.groups;
			for (var i=0; i < data.groups.length; i++){
				var g = data.groups[i];
				console.log(g);
			}
		},function(error){
			console.log (error);
		});
}
// Method the get the content of a group or inbox
async function do_list_talk(owner,groupname,groupowner,fulltext,offset,nb,firstseen){
	var data = new Webapi.ListTalk();
	data.sessionid = sessionid;
	data.owner = owner;
	data.groupname = groupname;
	data.groupowner = groupowner;
	data.fulltext = fulltext;
	data.offset = offset;
	data.nb = nb;
	data.firstseen = firstseen;
	await api.listTalk(data).then(function(data){
			console.log (data);
		},function(error){
			console.log(error);
		});
}
// List content for all groups
// Show the first 3 messages
async function do_list_talks(){
	if (groups != null){
		for (var i=0; i<groups.length; i++){
			var g = groups[i];
			console.log ("====== Owner: " + g.owner + " group name: " + g.name);
			await do_list_talk("",g.name,g.owner,[],0,3,"");
		}
	}else{
		console.log ("groups is null");
	}
}
	
async function main_job(){
	await do_login(email,pass);
	console.log (sessionid);
	if (sessionid != "empty"){
		await do_interest_check("",[],0,2,"");
		await do_list_groups ("",false);
		await do_list_talks ();
		await do_logout();
	}
}

main_job();
