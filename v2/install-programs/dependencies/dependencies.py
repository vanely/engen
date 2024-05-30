def someDependencyFunction():
  print("This message is coming from the dependencies directory")

def basicMaths(numOne, operand, numTwo):
  if (operand == "+"):
    return numOne + numTwo
  elif (operand == "-"):
    return numOne - numTwo
  elif (operand == "*"):
    return numOne * numTwo
  else (operand == "/"):
    return numOne / numTwo
