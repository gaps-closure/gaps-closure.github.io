## Constraint Solver Outputs **Review: Rajesh**

When the [conflict analyzer](#conflict-analyzer) finds a conflict it will print out a diagnostic.
Diagnostic generation produces commandline output
containing node types and grouped by constraints from minizinc

```
<constraint_name>: 
  (<source_node_type>) <file>:<function>@<line> -> (<dest_node_type>) <file>:<function>@<line> # for edges
  (<node_type>) <file>:<function>@<line> # for nodes  
``` 

Here's a possible example from example1:

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
solver will output a list of conflicts in json form. In this form,
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


**Include findMUS output file generated**
**Describe in 1-2 sentences each**
