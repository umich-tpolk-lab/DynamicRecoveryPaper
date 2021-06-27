function make_meanbold_datamat(path,filename)

runname = (filename); 
cd (path) % The toolbox outputs our mean-BOLD PLS files in the current directory
batch_plsgui(runname);

end
