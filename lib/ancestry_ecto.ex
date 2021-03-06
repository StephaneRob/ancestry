defmodule AncestryEcto do
  @moduledoc """
  AncestryEcto
  """

  @doc """
  List all roots records
  """
  @callback roots() :: [Ecto.Schema.t()]

  @doc """
  Check if record is root (has no ancestry)
  """
  @callback root?(record :: Ecto.Schema.t()) :: boolean()

  @doc """
  List ancestors ids of the record
  """
  @callback ancestor_ids(record :: Ecto.Schema.t()) :: [String.t() | Integer.t()]

  @doc """
  List ancestors of the record
  """
  @callback ancestors(record :: Ecto.Schema.t()) :: [Ecto.Schema.t()]

  @doc """
  Parent id of the record, nil for a root node
  """
  @callback parent_id(record :: Ecto.Schema.t()) :: nil | String.t() | Integer.t()

  @doc """
  Parent of the record, nil for a root node
  """
  @callback parent(record :: Ecto.Schema.t()) :: nil | Ecto.Schema.t()

  @doc """
  Direct children of the record
  """
  @callback children(record :: Ecto.Schema.t()) :: [Ecto.Schema.t()]

  @doc """
  Direct children ids of the record
  """
  @callback children_ids(record :: Ecto.Schema.t()) :: [String.t() | Integer.t()]

  @doc """
  Check if record has children
  """
  @callback children?(record :: Ecto.Schema.t()) :: boolean()

  @doc """
  Direct and indirect children of the record
  """
  @callback descendants(record :: Ecto.Schema.t()) :: [Ecto.Schema.t()]

  @doc """
  Direct and indirect children ids of the record
  """
  @callback descendant_ids(record :: Ecto.Schema.t()) :: [String.t() | Integer.t()]

  @doc """
  Sibling of the record, the record itself is included
  """
  @callback siblings(record :: Ecto.Schema.t()) :: [Ecto.Schema.t()]

  @doc """
  Sibling ids of the record, the record itself is included
  """
  @callback siblings_ids(record :: Ecto.Schema.t()) :: [String.t() | Integer.t()]

  @doc """
  true if the record's parent has more than one child
  """
  @callback has_siblings?(record :: Ecto.Schema.t()) :: boolean()

  @doc """
    Delete record and apply strategy to children
  """
  @callback delete(record :: Ecto.Schema.t()) ::
              {:ok, Ecto.Schema.t()} | {:error, Ecto.Schema.t()}

  defmacro __using__(options) do
    quote bind_quoted: [options: options] do
      @module options[:schema] || __MODULE__
      @app options[:app] || [@module |> Module.split() |> List.first()] |> Module.concat()

      @opts [
        module: @module,
        repo: options[:repo] || @app |> Module.concat("Repo"),
        column: options[:column] || :ancestry,
        attribute: options[:attribute] || {:id, :integer},
        orphan_strategy: options[:orphan_strategy] || :rootify
      ]

      alias AncestryEcto.{
        Ancestor,
        Changeset,
        Children,
        Descendant,
        Parent,
        Repo,
        Root,
        Subtree,
        Sibling
      }

      def roots do
        Root.list(@opts)
      end

      def root?(model) do
        Root.root?(model, @opts)
      end

      def ancestor_ids(model) do
        Ancestor.ids(model, @opts)
      end

      def ancestors(model) do
        Ancestor.list(model, @opts)
      end

      def parent_id(model) do
        Parent.id(model, @opts)
      end

      def parent(model) do
        Parent.get(model, @opts)
      end

      def has_parent?(model) do
        Parent.any?(model, @opts)
      end

      def children(model) do
        Children.list(model, @opts)
      end

      def child_ids(model) do
        Children.ids(model, @opts)
      end

      def children?(model) do
        Children.any?(model, @opts)
      end

      def descendants(model) do
        Descendant.list(model, @opts)
      end

      def descendant_ids(model) do
        Descendant.ids(model, @opts)
      end

      def siblings(model) do
        Sibling.list(model, @opts)
      end

      def sibling_ids(model) do
        Sibling.ids(model, @opts)
      end

      def has_siblings?(model) do
        Sibling.any?(model, @opts)
      end

      def subtree(model, options \\ []) do
        Subtree.list(model, options, @opts)
      end

      def subtree_ids(model) do
        Subtree.ids(model, @opts)
      end

      def delete(model) do
        Repo.delete(model, @opts)
      end

      def cast_ancestry(changeset, attrs) do
        Changeset.cast(changeset, attrs, @opts)
      end
    end
  end
end
