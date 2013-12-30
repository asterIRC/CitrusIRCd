The Citrus Inter-Server Protocol
================================

Citrus is a protocol for multi threaded IRC servers to share state info and messages beteween threads,
possibly on different systems. Servers implementing the Citrus TS system need not be IRC servers.

Protocol Details
================

This protocol requires careful uase of PI and PO to measure protocol lag.
This is so that in mesh IRC networks, a routing table can be built, thus entirely bypassing lag on short routes
by choosing a long route. No route in the table to any directly-linked server may be more than 3 hops long, to
prevent extreme lag caused by anti-congestion routing.

Protocol Commands
=================

A: ask for login username and UID

Syntax:
```
<Source UID> A <Lookup UID>
```

Reply:
```
<Client's server's UID> A <Lookup UID> <Account name> <Acc UUID>
```
Pretty self explanatory.
B: route a message

Syntax:
```
<Source ID> B <Dest ID> <Message type> :<Message contents>
```
Message Type can be any of:
* N which is a notice
* P which in IRC is a privmsg
* W which is a wall ops (destination must be a server or a channel ID)
* and SN, which is an all-servers bulletin (backend-to-backend link down???)

C: A server is (dis)Connecting to/from the Citrus network

Syntax:
```
<Source ID> C server.name/SERVERID <Encap type> <Conn type> 
```
Where server.name/SERVERID is the name of the server, a forward stroke and a server identification numeric used to address clients to that server.
Encap Type should be 'IRC' for an IRC server, 'D' for a disconnecting server and 'C' for a Citrus Native server.
Conn type must be D (if the server is removing itself from the network) or C (if the server is connecting). Alternatively during a net.burst, it may be 'B'
for 'Already connected.'

D: Associate a channel-ID the source ID is operator in to a channel name, which may be used as a shortcut

Syntax:
```
<Source ID> D <Channel ID> <Channel name>
```
Pretty self explanatory.

E: This server is (dis)connecting to the Citrus network

Syntax:
```
<Source> E server.name/SERVERID <Encap type> <Conn type> <Password> :<Server description>
```
Where server.name/SERVERID is the name of the server, a forward stroke and a server identification numeric used to address clients to that server.
Encap Type should be 'IRC' for an IRC server, 'D' for a disconnecting server and 'C' for a Citrus Native server.
Conn type must be D (if the server is removing itself from the network) or C (if the server is connecting).

F: Such and such user's status is being set

Syntax:
```
<Source ID (usually a services server)> F <Dest ID> <Status level>
```
Status level definitions:
* 0000-0999: No-Op (no special powers)
* 1000-1999: Voice (can speak when channel is moderated)
* 2000-9999: Operator (can change channel stati and modes, IRC mode +h)
* 3000-9999: Operator (protected from 2000-2999 operator actions, IRC mode +H)
* 4000-9999: Operator (protected from 2000-3999 operator actions, IRC mode +o)
* 5000-9999: Operator (protected from 2000-4999 operator actions, IRC mode +O)
* 6000-9999: Operator (protected from 2000-5999 operator actions, IRC mode +a or +U 6000:nickname)
* 7000-9999: Operator (protected from 2000-6999 operator actions, IRC mode +A or +U 7000:nickname)
* 8000-9999: Operator (protected from 2000-7999 operator actions, IRC mode +q or +U 8000:nickname)
* 9000-9990: Operator (protected from 2000-7999 operator actions, IRC mode +Q or +U 9000:nickname)
* 9990-9999: Override Network Operator or Channel Service

Signed stati are possible too.
* -0010 - -0019: Banned (IRC mode +B 0010:n!u@h) 
