/*
	Copyright (c) 2012, Simon Bingham
	
	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
	files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
	modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software 
	is furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
	LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
	IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

component accessors="true"
{

	/*
	 * Dependency injection
	 */	
	
	property name="Validator" getter="false";

	/*
	 * Public methods
	 */
	 	
	function init()
	{
		return this;
	}
	
	struct function deleteUser( required numeric userid )
	{
		var User = getUserByID( arguments.userid );
		var messages = {};
		if( User.isPersisted() )
		{
			transaction
			{
				EntityDelete( User );
				messages.success = "The user has been deleted.";
			}
		}
		else
		{
			messages.error = "The user could not be deleted.";
		}
		return messages;
	}
	
	function getUserByID( required numeric userid )
	{
		var User = EntityLoadByPK( "User", arguments.userid );
		if( IsNull( User ) ) User = newUser();
		return User;
	}

	function getUserByCredentials( required struct properties )
	{
		return EntityLoad( "User", arguments.properties, true );
	}

	array function getUsers()
	{
		return EntityLoad( "User", {}, "firstname" );		
	}
		
	function getValidator( required any User )
	{
		return variables.Validator.getValidator( theObject=arguments.User );
	}
	
	function newUser()
	{
		return EntityNew( "User" );
	}		
	
	function saveUser( required struct properties, required string context )
	{
		transaction
		{
			var User = ""; 
			User = getUserByID( Val( arguments.properties.userid ) );
			User.populate( arguments.properties );
			var result = variables.Validator.validate( theObject=User, Context=arguments.context );
			if( !result.hasErrors() )
			{
				EntitySave( User );
				transaction action="commit";
			}
			else
			{
				transaction action="rollback";
			}
		}
		return result;
	}
	
}