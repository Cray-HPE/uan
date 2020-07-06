@Library('dst-shared@release/shasta-1.3') _
rpmBuild (
    specfile: "uan-crayctldeploy.spec",
    channel: "casmcms-builds",
    slack_notify: ['SUCCESS','FAILURE'],
    product: "shasta-premium",
    target_node: "ncn",
    fanout_params: ["sle15sp1"],
    recv_triggers: ["cme-premium-cf"]
)
