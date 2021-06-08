defmodule Identicon do
    def hash_input(input) do
      hash = :crypto.hash(:md5, input)
      |> :binary.bin_to_list()
      %Identicon.Image{hex: hash}
    end
    def pick_color(%Identicon.Image{hex: [r, g, b | _tail ]} = image) do
      %Identicon.Image{image | color: {r, g, b}}
    end
    def build_grid(struct) do
      grid = Enum.chunk_every(struct.hex, 3)
      |> List.delete_at(-1)
      |> Enum.map(&mirror_row(&1))
      |> List.flatten()
      |> Enum.with_index()

      %Identicon.Image{struct | grid: grid}
    end
    def mirror_row(row) do
      row2 = Enum.reverse(row)
      Enum.dedup(row ++ row2)
    end

    def filter_add_cells(struct) do
      grid = Enum.filter(struct.grid, fn {code, _index} -> rem(code, 2)==0 end)
      %Identicon.Image{struct | grid: grid}
    end

    def build_pixel_map(%Identicon.Image{grid: grid} = image) do
      pixel_map =
      Enum.map(grid, fn({_code, index}) -> {{rem(index, 5) * 50, div(index, 5) * 50},{rem(index, 5) * 50+50, div(index, 5) * 50+50}} end)

      %Identicon.Image{image | pixel_map: pixel_map }
    end

    def build_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
      img = :egd.create(250,250)
      fill = :egd.color(color)
      Enum.each(pixel_map, fn({start, stop}) -> :egd.filledRectangle(img, start, stop, fill) end)
      :egd.render(img)
    end
    def save_image(img,filename) do
      :egd.save(img, filename)
    end
    def main do
      input = IO.gets("文字列を入力してください：")
      |> String.trim()
      hash_input(input)
      |> pick_color()
      |> build_grid()
      |> filter_add_cells()
      |> build_pixel_map()
      |> build_image()
      |> save_image("#{input}"<>".png")
    end
  end
