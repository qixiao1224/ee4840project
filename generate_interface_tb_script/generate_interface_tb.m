%This script takes an input file naming "input_output_port.txt" and 
%generate 3 blocks of code:
% 1.A module interface  
% 2.Testbench wires and regs
% 3.A module initiation
%into a output file naming "Interface_and_TB.txt"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%interface generation
port_file = fopen('./input_output_port.txt','r');
interface_file = fopen('./Interface.txt','w');

output_flag=0;

while ~feof(port_file)
    line = fgetl(port_file);
    first = sscanf(line,'%s',1);
    if (first=="input" || first=="----------break----------" || first=="output" || first=="module") 
        if (first=="output") 
            output_flag=1;
        end
        if (first=="module")
           line = fgetl(port_file);%dummy read to skip the module name
        end
    else
        %[var_name, value, type] = strtok(line, ' ');
        %value = str2double(value);
        %type = strtrim(type);
        data = textscan(line, '%s %d %s');
        var_name = data{1}{1};
        value = data{2}(1);
        type = data{3}{1};
        if (~output_flag)  %inputs generation
            if value > 1
                if (type=="reg")
                    fprintf(interface_file, 'input\treg\t[%d:0]\t%s;\n', value-1, var_name);
                else 
                    fprintf(interface_file, 'input\t\t[%d:0]\t%s;\n', value-1, var_name);
                end
            else
                if (type=="reg")
                    fprintf(interface_file, 'input\treg\t\t%s;\n', var_name);
                else 
                    fprintf(interface_file, 'input\t\t\t%s;\n', var_name);
                end
            end
        else %outputs generation
            if value > 1
                if (type=="reg")
                    fprintf(interface_file, 'output\treg\t[%d:0]\t%s;\n', value-1, var_name);
                else 
                    fprintf(interface_file, 'output\t\t[%d:0]\t%s;\n', value-1, var_name);
                end
            else
                if (type=="reg")
                    fprintf(interface_file, 'output\treg\t\t%s;\n', var_name);
                else 
                    fprintf(interface_file, 'output\t\t\t%s;\n', var_name);
                end
            end
        end    
    end   
end
fclose(port_file);
fclose(interface_file);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%testbench reg and wire generation
port_file = fopen('./input_output_port.txt','r');
connection_file = fopen('./Connection.txt','w');

output_flag=0;

while ~feof(port_file)
    line = fgetl(port_file);
    first = sscanf(line,'%s',1);
    if (first=="input" || first=="----------break----------" || first=="output" || first=="module") 
        if (first=="output") 
            output_flag=1;
        end
        if (first=="module")
           line = fgetl(port_file);%dummy read to skip the module name
        end
    else
        data = textscan(line, '%s %d %s');
        var_name = data{1}{1};
        value = data{2}(1);
        type = data{3}{1};
        if (~output_flag)  %inputs generation
            if value > 1
                fprintf(connection_file, 'reg\t[%d:0]\t%s;\n', value-1, var_name);
            else
                fprintf(connection_file, 'reg\t\t%s;\n', var_name);
            end
        else %outputs generation
            if value > 1
                fprintf(connection_file, 'wire\t[%d:0]\t%s;\n', value-1, var_name);
            else
                fprintf(connection_file, 'wire\t\t%s;\n', var_name);
            end
        end    
    end   
end
fclose(port_file);
fclose(connection_file);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initiation generation (wire name matched with port name)
%default instance name = modulename_0
port_file = fopen('./input_output_port.txt','r');
instance_file = fopen('./Instance.txt','w');

while ~feof(port_file)
    line = fgetl(port_file);
    first = sscanf(line,'%s',1);
    if (first=="input" || first=="----------break----------" || first=="output" || first=="module") 
        if (first=="output") 
            output_flag=1;
        end
        if (first=="module")
           module_name = fgetl(port_file); %store the module name
           fprintf(instance_file, '%s %s_0(\n', module_name, module_name);
        end
    else
        data = textscan(line, '%s %d %s');
        var_name = data{1}{1};
        if (feof(port_file))
            fprintf(instance_file, '\t.%s(%s)\n', var_name, var_name);
        else
            fprintf(instance_file, '\t.%s(%s),\n', var_name, var_name);
        end
 
    end  
    
end
fprintf(instance_file, ');');
fclose(port_file);
fclose(instance_file);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%