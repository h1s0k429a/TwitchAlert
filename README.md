# TwitchAlert

TwitchAlert is an example Godot application to demonstrate how to use the TwitchChat plugin. You can find the latest version of the TwitchChat plugin in the src/addons directory. To run this application, you must first obtain a Twitch chat user access token and then place the token, together with your account name and channel id in the src/twitch.cfg file. The current access token in the src/twitch.cfg is a fake one. You can obtain the token at https://twitchapps.com/tmi/ by granting access to the Twitch chat password generator. Make sure that you do not reveal the access token during any livestream or upload it to a public repository. Make sure debug setting is off on the TwitchChat node during livestreaming or your access token will be displayed in Godot's Output window. Removing the Twitch password generator from your Twitch connections at https://www.twitch.tv/settings/connections will invalidate all past access tokens. You can always grant access again to generate new tokens.




