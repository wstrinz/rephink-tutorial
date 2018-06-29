defmodule Rephink.Rephink.Todo do
  use Ecto.Schema
  import Ecto.Changeset


  schema "todos" do
    field :completed, :boolean, default: false
    field :task, :string

    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:task, :completed])
    |> validate_required([:task, :completed])
  end
end
