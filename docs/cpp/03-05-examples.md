## Example applications {#examples} 

### Example 2

Discuss the example at a high level. what is the intended structure? what is the cross domain policy? What is annotated why? Provide some src.

Example 2 is a simple example designed to gain insights and facilitate early development of CLOSURE toolchain for C++ programs. The targeted C++ features of the example are object instantiation and method calls, which, after partitioned by CLOSURE, are expected to be cross domain ones. The toplevel class `Example2` has an instance of `Extra`, which contains a private integer `a2LUE` field with the get method `getValue()`. 
In the imaginary security policy, the value of `a2LUE` is to be guarded, which means the `getValue()` method 
needs to be guarded. Two enclaves, Orange and Purple, are assumed in this policy. One initial constraints in the CLOSURE C++ toolchain is that a class is always assigned to an enclave in its entirety, not partially. Therefore, the `Extra` class and all its members will be assigned to the Purple enclave. The `Example` class is then assigned to the Orange enclave. This arrangement then fulfills the requirements of cross domain constructor and methods calls.

The following is a snippet of Example2.

```cpp
template <typename T, int label>
using annotate = T;

#define ORANGE 1

class Example2
{
private:
  Extra extra;

public:
  // @OrangeShareable
  annotate<int, ORANGE> myConstant;

  int getValue() {
    return this->extra.getValue();
  }

  Example2() : extra() {
  }
};

// @OrangeMain
int main(int argc, char **argv)
{
  Example2 e;
  printf("Hello Example 1: %d\n", e.getValue());
}
```

```cpp
class Extra : public Parent
{
private:
  // @Purple
  int a2LUE;

  // @PurpleOrangeConstructable
public:
  Extra() {
    a2LUE = 42;
  }

  // @PurpleOrangeCallable
  int getValue() {
     return this->a2LUE;
  }
};
```

### Foo/Bar (Ben)

Discuss the example at a high level. what is the intended structure? what is the cross domain policy? What is annotated why? Provide some src.

