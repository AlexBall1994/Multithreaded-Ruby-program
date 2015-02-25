##########################################################################
### CMSC330 Project 5: Multi-threaded Space Simulation                 ###
### Source code: space.rb                                              ###
### Description: Multi-threaded Ruby program simulating space travel   ###
### Student Name: ABALLER                                                  ###
##########################################################################

require "monitor"
Thread.abort_on_exception = true # to avoid hiding errors in threads


#------------------------------------
# Global Variables



$headerPorts = "=== Starports ==="
$headerShips = "=== Starships ==="
$headerTraveler = "=== Travelers ==="
$headerOutput = "=== Output ==="

$simOut = [] # simulation output

$starport = []
$starship = []
$traveler = []
$printMonitor = Monitor.new()

#----------------------------------------------------------------
# Starport
#----------------------------------------------------------------


class Starport
    def initialize (name,size)
        @name = name
        @size = size
        @ships = []
        @travelers = []
        @starM = Monitor.new()
        @departC = @starM.new_cond()
        @docked = @starM.new_cond()
    end

    def size
    @size
end

    def ships
        @ships
    end

    def travelers
        @travelers
    end

    def to_s
        @name
    end

    def shipCap
        ship = nil
        @ships.each{ |shipT|
        if shipT.passengers.length < shipT.size
            ship = shipT
            break
        end
    }


        ship
end


def docked
    @docked
end




def departC
    @departC
end


def arrive(spaceMan)
    @travelers.push(spaceMan)
end



def starM
    @starM
end


end
#------------------------------------------------------------------
# find_name(name) - find port based on name
def find_name(arr, name)
    arr.each { |p| return p if (p.to_s == name) }
    puts "Error: find_name cannot find #{name}"
        $stdout.flush
end
#------------------------------------------------------------------
# next_port(c) - find port after current port, wrapping around
def next_port(current_port)
    port_idx = $starport.index(current_port)
    if !port_idx
       puts "Error: next_port missing #{current_port}"
       $stdout.flush
       return $starport.first
   end

   port_idx += 1
   port_idx = 0 if (port_idx >= $starport.length)
   $starport[port_idx]
end
#----------------------------------------------------------------
# Starship
#----------------------------------------------------------------
class Starship
    def initialize (name, size)
       @name = name
               @size = size
       @passengers = []
       @current_loc = nil
       @previous_port = nil
       @current_port = nil
       @destination = nil
   end

   def size
    @size
end

def passengers
   @passengers
end

        def to_s
            @name
        end

        def current_port
            @current_port
        end

        def setInitial(new)
           @current_port = new
        end

        def previous_port
           @previous_port
        end

        def setPrev(new)
           @previous_port = new
        end

        def destination
            @destination
        end

        def setStop(new)
            @destination = new
        end
end


#----------------------------------------------------------------
# Traveler
#----------------------------------------------------------------


class Traveler
    def initialize(name, itinerary)
        @name = name
        @itinerary = itinerary
            @inPort = true
            @iten_iter = 0
        
    end

    def to_s
       @name
   end

    def iten_iter
       @iten_iter
   end

   def set_iten_iter(new_idx)
       @iten_iter = new_idx
   end

   

   def itinerary
    @itinerary
end

def inPort
   @inPort
end

    def setStation(new)
        @inPort = new
    end
end


#------------------------------------------------------------------
# read command line and decide on display(), verify() or simulate()


def readParams(fname)
    begin
        f = File.open(fname)
    rescue Exception => e
        puts e
        $stdout.flush
        exit(1)
    end


    section = nil
    f.each_line{|line|


        line.chomp!
        line.strip!
        if line == "" || line =~ /^%/
            # skip blank lines & lines beginning with %


        elsif line == $headerPorts || line == $headerShips ||
            line == $headerTraveler || line == $headerOutput
            section = line

        elsif section == $headerPorts
            parts = line.split(' ')
            name = parts[0]
                 size = parts[1].to_i
                 $starport.push(Starport.new(name,size))

        elsif section == $headerShips
            parts = line.split(' ')
            name = parts[0]
                        size = parts[1].to_i
                        $starship.push(Starship.new(name,size))

        elsif section == $headerTraveler
            parts = line.split(' ')
            name = parts.shift
            itinerary = []
            parts.each { |p| itinerary.push(find_name($starport,p)) }
            person = Traveler.new(name,itinerary)
            $traveler.push(person)
            find_name($starport,parts.first).arrive(person)

        elsif section == $headerOutput
            $simOut.push(line)

        else
            puts "ERROR: simFile format error at #{line}"
            $stdout.flush
            exit(1)
        end
    }
end


#------------------------------------------------------------------
#

def printParams()
    
    puts $headerPorts
    $starport.each { |s| puts "#{s} #{s.size}" }
    
    puts $headerShips 
    $starship.each { |s| puts "#{s} #{s.size}" }
    
    puts $headerTraveler 
    $traveler.each { |p| print "#{p} "
                               p.itinerary.each { |s| print "#{s} " } 
                               puts }

    puts $headerOutput
    $stdout.flush
end

#----------------------------------------------------------------
# Simulation Display
#----------------------------------------------------------------

def array_to_s(arr)
    out = []
    arr.each { |p| out.push(p.to_s) }
    out.sort!
    str = ""
    out.each { |p| str = str << p << " " }
    str
end

def pad_s_to_n(s, n)
    str = "" << s
    (n - str.length).times { str = str << " " }
    str
end

def ship_to_s(ship)
    str = pad_s_to_n(ship.to_s,12) << " " << array_to_s(ship.passengers)
    str
end

def display_state()
    puts "----------------------------------------"
    $starport.each { |port|
        puts "#{pad_s_to_n(port.to_s,13)} #{array_to_s(port.travelers)}"
        out = []
        port.ships.each { |ship| out.push("  " + (ship_to_s(ship))) }
        out.sort.each { |line| puts line }
    }
    puts "----------------------------------------"
end

#------------------------------------------------------------------
# display - print state of space simulation

def display()
    display_state()


    $starship.each { |shipT|
        shipT.setStop($starport[0])
    }

    $simOut.each {|o|
        puts o

        if o =~ /(\w+) (docking at|departing from) (\w+)/
            ship = find_name($starship,$1);
            action = $2;
            port = find_name($starport,$3);


            if (action == "docking at")
                port.ships.push(ship)
                    ship.setInitial(port)
                    ship.setPrev(ship.current_port)
                    ship.setStop(nil)
                
                
            else
               port.ships.delete(ship)
                ship.setStop(next_port(port))
                ship.setPrev(ship.current_port)
                ship.setInitial(nil)
           

           end




       elsif o =~ /(\w+) (board|depart)ing (\w+) at (\w+)/
        person = find_name($traveler,$1);
        action = $2;
        ship = find_name($starship,$3);
        port = find_name($starport,$4);
        


        if (action == "board")
            ship.passengers.push(person)
            port.travelers.delete(person)
                person.setStation(false)
                person.set_iten_iter(person.iten_iter + 1)
                        
        else
            port.travelers.push(person)                
            ship.passengers.delete(person)
            person.setStation(true)
        end



        else
            puts "% ERROR Illegal output #{o}"
        end
        display_state()
    }


end


#------------------------------------------------------------------
# verify - check legality of simulation output


def verify
    validSim = true

    $starship.each { |shipT|
        shipT.setStop($starport[0])
    }


    $simOut.each {|o|
        if o =~ /(\w+) (docking at|departing from) (\w+)/
            ship = find_name($starship,$1);
            action = $2;
            port = find_name($starport,$3);
            if (action == "docking at")
                if port != ship.destination
                    validSim = false
                elsif port.ships.length >= port.size
                    validSim = false
                else
                     port.ships.push(ship)
                    ship.setStop(nil)
                    ship.setInitial(port)
                    ship.setPrev(ship.current_port)
                   

                end
            else

                if port.ships.index(ship).nil?
                    validSim = false

                else
                    port.ships.delete(ship)
                    ship.setInitial(nil)
                    ship.setPrev(ship.current_port)
                    ship.setStop(next_port(port))
                    
                    

                end
            end


        elsif o =~ /(\w+) (board|depart)ing (\w+) at (\w+)/
            person = find_name($traveler,$1);
            action = $2;
            ship = find_name($starship,$3);
            port = find_name($starport,$4);


            if (action == "board")
                if port.ships.index(ship).nil?
                    validSim = false
                elsif ship.passengers.length >= ship.size
                    validSim = false
                elsif !person.inPort
                    validSim = false
                else
                    ship.passengers.push(person)
                    port.travelers.delete(person)
                            person.setStation(false)
                            person.set_iten_iter(person.iten_iter + 1)
                            
                end
            else
                if port.ships.index(ship).nil?
                    validSim = false
                elsif port != person.itinerary[person.iten_iter]
                    validSim = false
                elsif (person.iten_iter > 1 && (person.itinerary[person.iten_iter] == person.itinerary[person.iten_iter - 1]))
                   validSim = false
               elsif ship.passengers.index(person).nil?
                   validSim = false
               else
                    port.travelers.push(person)
                    ship.passengers.delete(person)
                    person.setStation(true)
                
               
                end
        end
    else
        puts "% ERROR Illegal output #{o}"
    end
}

$starship.each{ |shipT|
    if shipT.passengers.length > 0
        validSim = false;
    end
}


$traveler.each { |travr|
    if ((travr.iten_iter != travr.itinerary.length - 1) || !travr.inPort)
        validSim = false
    end
}

        return validSim


end


#------------------------------------------------------------------
# simulate - perform multithreaded space simulation


def shipSimulator(ship)
    while true
            dPort = ship.destination
            dPort.starM.synchronize {
                    dPort.docked.wait_until {
                        dPort.ships.length < dPort.size
                    }
            dPort.ships.push(ship)
            ship.setInitial(dPort)
            ship.setStop(nil)
            ship.setPrev(ship.current_port)
            
            
            dPort.departC.broadcast()


            $printMonitor.synchronize {
                puts "#{ship} docking at #{dPort}"
                $stdout.flush
            }

        }
        sleep (0.001)


        dPort.starM.synchronize {
            dPort.ships.delete(ship)
            ship.setInitial(nil)
            ship.setPrev(ship.current_port)
            
            ship.setStop(next_port(dPort))
            dPort.docked.broadcast()

            $printMonitor.synchronize {
                puts "#{ship} departing from #{dPort}"
                $stdout.flush
            }
        }
    end
end


def travelerSimulator(trav)
   
    while ((trav.iten_iter != trav.itinerary.length - 1))
        dPort = trav.itinerary[trav.iten_iter]
        ship = nil


        dPort.starM.synchronize {
            dPort.departC.wait_until {
                dPort.ships.length > 0 && !dPort.shipCap.nil?
            }
            ship = dPort.shipCap
            ship.passengers.push(trav)
            dPort.travelers.delete(trav)
            trav.setStation(false)
            trav.set_iten_iter(trav.iten_iter + 1)
            
             dPort.docked.broadcast()

            $printMonitor.synchronize {

                puts "#{trav} boarding #{ship} at #{dPort}"
                $stdout.flush()
            }
        }
        dPort = trav.itinerary[trav.iten_iter]
        sleep (0.001)


        dPort.starM.synchronize {
            dPort.departC.wait_until {
                ship.current_port == dPort
            }
            ship.passengers.delete(trav)
            dPort.travelers.push(trav)
            trav.setStation(true)
            dPort.docked.broadcast()


            $printMonitor.synchronize {
                puts "#{trav} departing #{ship} at #{dPort}"
                $stdout.flush
            }
        }
    end
end


def simulate()
    $starship.each { |shipT|
        shipT.setStop($starport[0])
    }


    shipThread = []
    travelThread = []



    $starship.each { |s|
        shipThread.push(Thread.new {
            shipSimulator(s)
            })

    }


    $traveler.each { |t|
        travelThread.push(Thread.new {
            travelerSimulator(t)
            })
    }


    travelThread.each { |thread|
     thread.join()
 }
end


#------------------------------------------------------------------
# main - simulation driver

def main
    if ARGV.length != 2
        puts "Usage: ruby space.rb [simulate|verify|display] <simFileName>"
        exit(1)
    end
    
    # list command line parameters
    cmd = "% ruby space.rb "
    ARGV.each { |a| cmd << a << " " }
    puts cmd
    
    readParams(ARGV[1])
  
    if ARGV[0] == "verify"
        result = verify()
        if result
            puts "VALID"
        else
            puts "INVALID"
        end

    elsif ARGV[0] == "simulate"
        printParams()
        simulate()

    elsif ARGV[0] == "display"
        display()

    else
        puts "Usage: space [simulate|verify|display] <simFileName>"
        exit(1)
    end
    exit(0)
end

main

