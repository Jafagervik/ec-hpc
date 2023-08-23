

# TODO: Add includes over here

function main()
  if length(ARGS) != 2
    print("Oops, please select which version you want to run.")
    exit(1)
  end

  if ARGS[2] == "P"
    #parallel()
    nothing
  else
    # serial()
    nothing
  end
end

main()
