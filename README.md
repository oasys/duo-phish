# Duo Phish

A quick proof of concept tool to use the Duo API to send a phishing push to a list of users.

## Requirements

`gem install duo_api`

### credentials
Select "Applications" from the Duo Admin Panel.  Select "Protect an Application", and choose Duo Auth API from the list.  Copy the Integration Key, Secret Key, and API hostname from the "Details" section.  Under Settings > General, set "Name" to the value to be sent in the push message.

## References

[Duo Auth API](https://duo.com/docs/authapi)

## Future

- Use the Duo Admin API to dynamically select a group of users, rather than manually specify.
- Push a message to (or email) the user giving feedback that they Approved a bogus push.
