## Constraint Solver Outputs {#appendix-solver-outputs}

When the [conflict analyzer](#conflict-analyzer) cannot find an assignment that simultaneously
satisfies all constraints entailed by the CLE annotations on the program under analysis, it will 
print out a diagnostic. The diagnostic is based on a minimum unsatisfiable subset
of constraints determined by the findMUS utility of Minizinc, which groups
conflicts by constraint (name) with references to the PDG nodes and edges
involved in the conflict. The diagnostic is further enhanced with source file and 
line number references for use by the [CVI](#cvi) plugin to provide contextual guidance to
the developer. 

When the conflict analyzer finds a satisfying assignment it generates a `topology.json` file
as described in the [cross-domain cut specification](#xd-assignment) section.


```
<constraint_name>: 
  (<source_node_type>) <file>:<function>@<line> -> (<dest_node_type>) <file>:<function>@<line> # for edges
  (<node_type>) <file>:<function>@<line> # for nodes  
``` 

Here's an example based on example1 with unsatisfiable annotations:

```
XDCallAllowed
    (Inst_FunCall) /workspaces/build/apps/examples/example1/annotated-working/example1.c@get_a:85 -> (FunctionEntry) annotated/example1.c@get_a:46
    (Inst_FunCall) /workspaces/build/apps/examples/example1/annotated-working/example1.c@ewma_main:93 -> (FunctionEntry) annotated/example1.c@ewma_main:69

    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:81
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@get_a.a:56
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:87
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:55
    (Inst_Ret) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:90
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:84
    (Inst_Br) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:89
    (Inst_Br) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:84
    (Inst_FunCall) /workspaces/build/apps/examples/example1/annotated-working/example1.c@llvm.dbg.declare:75
    (Inst_FunCall) /workspaces/build/apps/examples/example1/annotated-working/example1.c@get_a:85
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@get_a.a:55
    (Inst_FunCall) /workspaces/build/apps/examples/example1/annotated-working/example1.c@llvm.dbg.declare:39
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:84
    (Inst_FunCall) /workspaces/build/apps/examples/example1/annotated-working/example1.c@get_b:86
    (Inst_FunCall) /workspaces/build/apps/examples/example1/annotated-working/example1.c@llvm.dbg.declare:81
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:75
    (Inst_FunCall) /workspaces/build/apps/examples/example1/annotated-working/example1.c@llvm.dbg.declare:84
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:69
    (Inst_Br) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:84
    (Inst_Ret) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:56
    (Inst_Br) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:84
    (Inst_FunCall) /workspaces/build/apps/examples/example1/annotated-working/example1.c@calc_ewma:87
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:69
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:69
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@get_a.a:55
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:69
    (Inst_FunCall) /workspaces/build/apps/examples/example1/annotated-working/example1.c@printf:88
    (Inst_FunCall) /workspaces/build/apps/examples/example1/annotated-working/example1.c@ewma_main:93
    (Inst_FunCall) /workspaces/build/apps/examples/example1/annotated-working/example1.c@llvm.dbg.declare:78
    (Inst_Ret) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:65
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:84
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:84
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:87
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:85
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:86
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:87
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:88
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:84
    (Inst_Other) /workspaces/build/apps/examples/example1/annotated-working/example1.c@None:84
```

When `--output-json` mode is activated the
solver will output a list of conflicts in JSON format. In this format,
it can be read by [CVI](#cvi).

```json
[
  {
    "name": "XDCallAllowed",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 85,
            "character": -1
          },
          "end": {
            "line": 85,
            "character": -1
          }
        }
      },
      {
        "file": "annotated/example1.c",
        "range": {
          "start": {
            "line": 46,
            "character": -1
          },
          "end": {
            "line": 46,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "XDCallAllowed",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 93,
            "character": -1
          },
          "end": {
            "line": 93,
            "character": -1
          }
        }
      },
      {
        "file": "annotated/example1.c",
        "range": {
          "start": {
            "line": 69,
            "character": -1
          },
          "end": {
            "line": 69,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 81,
            "character": -1
          },
          "end": {
            "line": 81,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 56,
            "character": -1
          },
          "end": {
            "line": 56,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 87,
            "character": -1
          },
          "end": {
            "line": 87,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 54,
            "character": -1
          },
          "end": {
            "line": 54,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 90,
            "character": -1
          },
          "end": {
            "line": 90,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 84,
            "character": -1
          },
          "end": {
            "line": 84,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 89,
            "character": -1
          },
          "end": {
            "line": 89,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 84,
            "character": -1
          },
          "end": {
            "line": 84,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 75,
            "character": -1
          },
          "end": {
            "line": 75,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 85,
            "character": -1
          },
          "end": {
            "line": 85,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 54,
            "character": -1
          },
          "end": {
            "line": 54,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 39,
            "character": -1
          },
          "end": {
            "line": 39,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 84,
            "character": -1
          },
          "end": {
            "line": 84,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 86,
            "character": -1
          },
          "end": {
            "line": 86,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 81,
            "character": -1
          },
          "end": {
            "line": 81,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 75,
            "character": -1
          },
          "end": {
            "line": 75,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 84,
            "character": -1
          },
          "end": {
            "line": 84,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 69,
            "character": -1
          },
          "end": {
            "line": 69,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 84,
            "character": -1
          },
          "end": {
            "line": 84,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 56,
            "character": -1
          },
          "end": {
            "line": 56,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 84,
            "character": -1
          },
          "end": {
            "line": 84,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 87,
            "character": -1
          },
          "end": {
            "line": 87,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 69,
            "character": -1
          },
          "end": {
            "line": 69,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 69,
            "character": -1
          },
          "end": {
            "line": 69,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 54,
            "character": -1
          },
          "end": {
            "line": 54,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 69,
            "character": -1
          },
          "end": {
            "line": 69,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 88,
            "character": -1
          },
          "end": {
            "line": 88,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 93,
            "character": -1
          },
          "end": {
            "line": 93,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 78,
            "character": -1
          },
          "end": {
            "line": 78,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 65,
            "character": -1
          },
          "end": {
            "line": 65,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 84,
            "character": -1
          },
          "end": {
            "line": 84,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 84,
            "character": -1
          },
          "end": {
            "line": 84,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 87,
            "character": -1
          },
          "end": {
            "line": 87,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 85,
            "character": -1
          },
          "end": {
            "line": 85,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 86,
            "character": -1
          },
          "end": {
            "line": 86,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 87,
            "character": -1
          },
          "end": {
            "line": 87,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 88,
            "character": -1
          },
          "end": {
            "line": 88,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 84,
            "character": -1
          },
          "end": {
            "line": 84,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  },
  {
    "name": "",
    "description": "TODO",
    "source": [
      {
        "file": "/workspaces/build/apps/examples/example1/annotated-working/example1.c",
        "range": {
          "start": {
            "line": 84,
            "character": -1
          },
          "end": {
            "line": 84,
            "character": -1
          }
        }
      }
    ],
    "remedy": []
  }
]  
```
