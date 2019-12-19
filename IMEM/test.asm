addi a0, a0, 14
addi a1, a1, 22
bltu a0, a1, less_than
xori a5, a5, 0xFF
j    end
less_than:
xori a6, a6, 0xFF
end:
add zero, zero, zero