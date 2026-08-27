**UDC Project — Working Principle:**
My project is an 8-bit programmable Up-Down Counter implemented in Verilog. The counter is configured through four registers: Preload, Upper Limit, Lower Limit, and Cycle Count. The registers are selected using A1:A0 and programmed through the Din bus using the active-low ncs and nwr signals.

After configuration, a START pulse loads the preload value into the counter. The counter then increments on every clock cycle until it reaches the upper limit, automatically changes direction, and decrements until it reaches the lower limit. It then changes direction again and counts upward until it returns to the preload value.

This complete sequence "Preload -> Upper Limit -> Lower Limit -> Preload" is considered one cycle. The programmed Cycle Count Register determines how many such cycles are performed. After the required number of cycles, the ec (end-cycle) signal is asserted and counting stops.

The design also includes error detection, which checks whether the preload value lies outside the programmed counting range. If Preload < Lower-Limit or Preload > Upper Limit, the err flag is asserted.
