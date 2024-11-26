{...}: {
  security.pam.yubico = {
    enable = true;
    debug = false;
    control = "required";
    mode = "challenge-response";
    id = [
      "19649094"
      "19649058"
    ];
  };
}
