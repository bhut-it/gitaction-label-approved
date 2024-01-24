# Label para aprovações de PR

Esse git action aplica um label de sua escolha em PR`s que atingem um número determinado de aprovações.

## Uso

```workflow
on: pull_request_review
name: Label para aprovações de PR
jobs:
  labelWhenApproved:
    name: Label quando aprovado
    runs-on: ubuntu-latest
    steps:
    - name: Label quando aprovado
      uses: bhut-it/gitaction-label-approved@main
      env:
        APPROVALS: "2"
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        ADD_LABEL: "approved"
        LABEL_COLOR: "0E8A16"
```

## Licença

Esse projeto está sobe a licença [MIT License](LICENSE).
