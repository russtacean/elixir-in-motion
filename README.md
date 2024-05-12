# elixir-in-motion
**Current status: complete**

Implementation of exercises from the book "Elixir in Action" by Sasa Juric. Goofed the repo name, because apparently I can't read.

### Overview
This book is an excellent look into the BEAM runtime with Elixir, and how to build a scalable, reliable, fault-tolerant system with these tools. 

It starts simple with an introduction to functional programming and how to write functions and use the data structures that Elixir provides. We then move to creating our own immutable data structures, working up to a simple to-do list module with an associated struct. 

From here, we begin working through how to provide a stateful server as an interface to this to-do list. The book introduces Genservers, Supervisors, Tasks, and Agents as a means of writing this application in a way that utilizes the strengths of the Erlang OTP and the BEAM VM running inside of it. Eventually we work our way up to creating a distributed system, that has multiple nodes capable of keeping track of todo list state, and allowing for stable operation with continuity of data even if a node currently serving the todo list goes down. 
