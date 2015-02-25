# Multi Threaded Ruby Program that simulates space program

My Work: Space.rb

To run:  ruby space.rb [simulate|verify|display] <simFileName>

This project just shows my work with multithreading in ruby.  Below is the included project description.  



	

Project Description
Space Simulation Rules
We will begin by describing how the space simulation works. In the simulation, there will be starships traveling between starports, and passengers traveling between starports, each with an itinerary. There are a number of rules governing how starships and travelers may move between starports.

    Starports

        A list of starports (and its capacity in ships) is provided. 

    Starships

        A list of starships (and its capacity in travelers) is provided.

        Starships are initially in space (not docked to a starport).

        Starships visit starports, in order from first to last in the list. When a starship visits the last starport in the list, it repeats the process starting from the first starport on the list.

        The total number of starships docked at a starport must not exceed the capacity of the starport. If there are multiple starships waiting to dock with a starport, the order they dock is unspecified.

    Travelers

        A list of travelers (and their itinerary) is provided.

        Each traveler's itinerary specifies which starport they must visit, and in which order. Travelers ride starships from port to port on their itinerary until they reach their final destination.

        The same starport may occur on the itinerary multiple times, but may not be adjacent to itself.

        At the start of the simulation, each traveler is at the first starport on their itinerary.

        Travelers wait at starports until a starship arrives, then try to board the starship and ride it to the next starport on the traveler's itinerary. Travelers may ride aboard any starship, as long as the capacity of the starship is not exceeded. If multiple travelers are trying to board a starship, the order they do so is unspecified.

        When a starship carrying a traveler arrives at the next starport on the traveler's itinerary, the traveler may attempt to disembark (depart the starship and enters the starport) while the starship is docked to the starport.

        It is possible that a traveler at a starport may miss boarding a starship as it passes through. In that case, the traveler remains at the starport and waits for an opportunity to board another starship.

        Similarly, a traveler riding on a starship may miss the opportunity to leave the starship while it is in port. In that case the traveler remains on the starship to wait for another opportunity to disembark at the desired starport.

        Travelers continue moving from starport to starport until they reach the final starport on their itinerary.

        The simulation ends when all travelers reach the final starport on their itinerary.

Space Simulation Outputs
A space simulation may be described by a number of simulation events, and the order they occur. Four simulation events and their associated messages are:

    starship docking at starport
    starship departing from starport
    traveler boarding starship at starport
    traveler departing starship at starport 

The simulator must output these simulation messages in the order they occur. These messages (and their order of occurrence) may then be analyzed and used to either display the state of the simulation, or to discover whether the simulation results are valid.

Because the simulation is multithreaded, the order messages are output is dependent on the thread scheduler. Running the same simulation will likely produce different outputs each time.

The simulation output provided in the public tests is simply an example of one possible output. The output of your simulator does not need to match it exactly. In fact it will be unlikely for your simulation output to be identical to the example output provided, especially for large numbers of threads.

Space Simulation Parameters
Each space simulation is performed for a specific set of simulation parameters. These parameters are stored in a simulation file, and include the following:

    Starports - name of each starport and its capacity
    Starships - name of each starship and its capacity
    Travelers - name of each traveler followed by list of starports in itinerary
    Output - possible simulation output for simulation 

The following is an example simulation file:

=== Starports ===
Earth 1
Vulcan 1
=== Starships ===
Enterprise 1
=== Travelers ===
Kirk Earth Vulcan 
=== Output ===
Enterprise docking at Earth
  Kirk boarding Enterprise at Earth
Enterprise departing from Earth
Enterprise docking at Vulcan
  Kirk departing Enterprise at Vulcan

Space Simulation Driver
Code is provided in the initial space.rb file to read in (and print out) the simulation parameters. Code is also provided to examine the command line parameters specifying the file containing simulation parameters, and whether the program should perform a simulation or simply display or verify the feasibility of the simulation output. The program may be invoked as:

     ruby space.rb [simulate|display|verify] simFileName

So typing ruby space.rb simulate public1.in would execute a simulation using the simulation parameters in public1.in (ignoring any example simulation output in the file), while typing ruby space.rb verify public1.in would perform an analysis of the simulation output in public1.in to determine whether it is feasible.

The code in space.rb outputs simulation parameters before simulation output, so that its output (if saved in a file) may be passed directly to the simulation display/verify routines for use in debugging your simulation.
Project Implementation
For this project, you are required to implement three major functions: display, verify, and simulate. The three parts may be implemented independently, though display and verify are similar.
Part 1: Simulation Display
A multithreaded simulation can clearly have many different behaviors, depending on the thread scheduler. One way to help determine whether a simulation is proceeding correctly (i.e., avoiding data races) is to model the state of the simulation by processing the simulation outputs. The model can then be used to display the state of the simulation, and/or determine its validity.

The first part of your project is to implement a model of the simulation (by processing simulation event messages) sufficiently detailed to display the following

    Starships at each starport
    Travelers at each starport
    Travelers on board each starship 

Your code should display the initial state of the simulation. Then it should list each simulation event messages in order, followed by a display of the state of the simulation after each event.

For instance, for the simulation parameters in public1.in described above, your code should display the initial state of the simulation as follows:

----------------------------------------
Earth         Kirk 
Vulcan        
----------------------------------------  

Your code should then process the simulation event messages in the simulation output, displaying the message and the resulting state. For instance, after processing the message Enterprise docking at Earth in the simulation output, your model should contain enough information to display the following:

----------------------------------------
Enterprise docking at Earth
----------------------------------------
Earth         Kirk 
  Enterprise  
Vulcan        
----------------------------------------
Kirk boarding Enterprise at Earth
----------------------------------------
Earth         
  Enterprise  Kirk 
Vulcan        
----------------------------------------
Enterprise departing from Earth
----------------------------------------
Earth         
Vulcan        
----------------------------------------
Enterprise docking at Vulcan
----------------------------------------
Earth         
Vulcan        
  Enterprise  Kirk 
----------------------------------------
Kirk departing Enterprise at Vulcan
----------------------------------------
Earth         
Vulcan        Kirk 
  Enterprise  
----------------------------------------

For the simulation display part of the project, you may assume the sample simulation output is valid.

Part 2: Simulation Verifier

It should be clear that a multithreaded simulation may have many different behaviors, depending on the thread scheduler. However, there are certain restrictions on the simulation output, e.g., travelers can board starships only when those starships are docked at the starport. To help you debug your simulator, you will write a verifier to examine your simulation outputs and checks whether they are valid (i.e., follows all the simulation rules in the project description).

The list of possible errors in the simulation output is huge, so you only need to check some common errors associated with data races resulting from incorrect synchronization. Many of these errors manifest as missing or out-of-order simulation messages. Some conditions you need to check are:

    Starships are traveling between starports in the correct order
    Starships always dock at a starport before leaving it
    Starships do not exceed the capacity of a starport
    Travelers follow their itinerary
    Travelers only board or leave a starship while it is at a starport
    Travelers do not exceed the capacity of a starship
    All travelers have reached their final destination when simulation ends 

Your verifier should output either "VALID" or "INVALID", depending on whether any illegal output is found.

Part 3: Space Simulation
Finally, you will write a Ruby program to performs a multithreaded simulation using the simulation parameters supplied (possibly reusing your code and data structures from part 1). Your simulation should be implemented as follows.

    Each starship and traveler in the simulation must be represented by its own thread. Thus, if you are simulating m starships and n travelers, you should be creating m+n threads.

    The initial state of the simulation should be as described in the space simulation rules (i.e., all travelers at the first starport in their itinerary, all starships poised to enter the first starport in the list of starports).

    You must use synchronization (i.e., Ruby monitors) to avoid data races and ensure your simulation is valid. You must use conditional variables to ensure your simulation uses synchronization efficiently.

    Initially you may use a single monitor and conditional variable for the entire simulation. For a more efficient implementation you should have a separate monitor for each starport, and multiple conditional variables for each monitor.

    Each starship should sleep for 0.001 seconds after docking at a starport (by calling "sleep 0.001"). Each traveler should sleep for 0.001 seconds after departing a starship. The thread should release any locks it has acquired before calling sleep.

    The simulation ends when all travelers have arrived at their final starport. To determine when this condition is reached, each traveler thread should exit when its traveler reaches its final starport, and the main thread can call join on all the traveler threads. Notice that it is legal if starship threads continue running for a while even after all passengers have reached their final destinations, since the join is not instantaneous.

    You should set Thread.abort_on_exception = true in your code, to detect errors if any thread throws an exception.

    In order to see what's going on during your simulation, your program must print out various messages as simulation events occur. For the simulation output to make sense, you must do the following:

        Create a lock (e.g., $printMonitor) that all threads must acquire when printing messages for simulation events
        Before a thread prints out the message for a simulation event, acquire both the lock for printing messages, and the lock preventing data races for the simulation event
        Immediately after printing, and before you release either locks, call $stdout.flush to flush the simulation message to standard output. 

    Your code for printing simulation output may look like the following:

      starportMonitor.synchronize { 
        ...starship docks at starport...
        $printMonitor.synchronize { 
          puts "starship docking at starport"
          $stdout.flush
        }
      }

    Following the rules above should ensure that if you build the simulation correctly, your simulation output will be valid. Otherwise, you might get strange interleavings of output messages that look incorrect even if your simulation code is actually correct.

When testing your simulator, the submit server tests will be running a verify program on your simulation output to ensure it follows all the simulation rules given in the project description, and that no errors are introduced due to data races.

The submit server tests will ignore any lines output beginning with "%".

TAs will look at your submitted code to check that you are using synchronization correctly. 
