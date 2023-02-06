from brownie import FundMe, MockV3Aggregator, accounts, config, network
from scripts.helpful_scripts import (
    get_account,
    deploy_mocks,
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
)
import time


def deploy_fund_me():
    account = get_account()
    # pass the price feed address into out fundMe contract

    # if we are on persistent network like rinkeby, use the assocaited address
    # else, deploy mocks (or forks?)

    # To deploy on live chain
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]
    else:  # to deploy if on development chain
        deploy_mocks()
        price_feed_address = MockV3Aggregator[-1].address

    fund_me = FundMe.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get(
            "verify"
        ),  # Public source is used to verify contract
    )
    print(f"Contract deployed to {fund_me.address}")
    return fund_me


def main():
    deploy_fund_me()
    time.sleep(1)
