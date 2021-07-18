def yaml_write(data, filename):
    f = open(filename, "w+")
    for key in data:
        f.write(f"{key}:\n- {data[key]}\n")


def yaml_read(data, filename):
    try:
        with open(filename) as f:
            for lineKey in f:
                key = lineKey[:-2]
                lineVal = next(f)
                val = lineVal[2:-1]
                data[key] = val
    except StopIteration:
        print("End")


if __name__ == "__main__":
    data = {}
    # data["a"] = "egfsgs"
    # data["b"] = "plmdwd"
    # data["c"] = "wdfegd"

    # yaml_write(data, "data.yaml")
    yaml_read(data, "data.yaml")

    print(data)
