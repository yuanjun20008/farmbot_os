defmodule FarmbotCore.RegimenInstanceAssetWorkerTest do
  use ExUnit.Case
  alias FarmbotCore.{Asset.RegimenInstance, AssetWorker}
  alias Farmbot.TestSupport.AssetFixtures
  use Mimic

  describe "regimen instance worker" do
    test "schedules sequence" do
      seq = AssetFixtures.sequence()

      regimen_instance =
        AssetFixtures.regimen_instance(
          %{regimen_items: [%{time_offset: 10_000_000, sequence_id: seq.id}]},
          %{},
          %{started_at: DateTime.utc_now()}
        )

      {:ok, pid} = AssetWorker.start_link(regimen_instance)
      state = %{regimen_instance: regimen_instance}
      result = GenServer.cast(pid, {:schedule, state})
      assert :ok == result
      # expect(FarmbotCeleryScript, :schedule, 1, fn _ast, _at, _data -> 1 end)
    end
  end
end
