

a = 123

a = 10
if a == 2 * 5:
	print(1337)
elif a == 2 * 2:
	print(4444)
elif a == 2:
	print(2222)
else:
	print(1111)

def fun(a):
	for n in range(a):
		print(n)


fun(5)


print(a)
print(a,a,a)




l = [56,78,90]

l.append(100)

print(l, l[3] / 10.1)
# print(a.__class__.__name__.__class__.__bases__[0])
# print(a.__class__.__class__.__subclasses__(a.__class__.__name__.__class__.__bases__[0]))


import math

# By the fundamental theorem of arithmetic, every integer n > 1 has a unique factorization as a product of prime numbers.
# In other words, the theorem says that n = p_0 * p_1 * ... * p_{m-1}, where each p_i > 1 is prime but not necessarily unique.
# Now if we take the number n and repeatedly divide out its smallest factor (which must also be prime), then the last
# factor that we divide out must be the largest prime factor of n. For reference, 600851475143 = 71 * 839 * 1471 * 6857.
def compute():
	n = 600851475143
	while True:
		p = smallest_prime_factor(n)
		if p < n:
			n //= p
		else:
			return n


# Returns the smallest factor of n, which is in the range [2, n]. The result is always prime.
def smallest_prime_factor(n):
	for i in range(2, int(math.sqrt(n)) + 1):
		if n % i == 0:
			return i
	return n  # n itself is prime


print(compute())
