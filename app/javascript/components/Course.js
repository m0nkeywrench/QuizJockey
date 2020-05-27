import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from "prop-types";

// ランダムに配列をシャッフル
const nativeShuffle = ([...array]) => {
  for (let i = array.length - 1; i >= 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
  return array;
}

// シャッフルした配列を一時的に保存しておく
var latestArray;

//選択肢
function Choice (props) {
  if (props.answering === false && props.answer === props.choice) {
    var buttonColor = "correct-answer";
  } else if (props.latestChoice === props.choice) {
    var buttonBorder = "choosed";
  }

  return (
    <React.Fragment>
      <button 
       onClick={() => props.onClick(props.answer, props.choice)} 
       className={"choose-button " + buttonColor + " " + buttonBorder}
      >{props.choice}</button>
    </React.Fragment>
  );
}

// 正誤結果表示
function Correctness (props) {
  if (props.collectness) {
    return (<div className="correct"><span></span></div>);
  } else {
    return (<div className="incorrect"><span></span></div>);
  }
}

// 次へボタン
function NextButton (props) {
  return (  
    <React.Fragment>
      <a href="#"
       onClick={props.onClick} 
       className="link-button main-color"
      >次へ</a>
    </React.Fragment>
  );
}

// 最終結果画面
function Result (props) {
  return (
    <React.Fragment>
      <div className="quiz-board__main--result">
        <div className="result-text">
          {props.history.length}問中{props.history.filter(word => word).length}問正解!
        </div>
        <div className="result-buttons">
          <div onClick={() => location.reload()} className="link-button main-color result-buttons--inner">
            再挑戦する
          </div>
          <a href='/' className="link-button gray result-buttons--inner">
            トップに戻る
          </a>
        </div>
        
      </div>
    </React.Fragment>
  );
}

// 4択フィールドを管理
class Question extends React.Component {
  // データを受け取り、4択を生成する
  renderChoice (choice) {
    return (
      <React.Fragment>
        <Choice
        answer={this.props.question.answer}
        choice={choice}
        latestChoice={this.props.latestChoice}
        onClick={(a, c) => this.props.onClick(a, c)}
        answering={this.props.answering}
        />
      </React.Fragment>
    );
  }

  render() {
    // 分岐が行われているのは回答画面表示時に選択肢の位置が変わってしまわないようにするため
    var choices;
    if (this.props.answering) {
      choices = nativeShuffle([
        this.props.question.answer,
        this.props.question.wrong1,
        this.props.question.wrong2,
        this.props.question.wrong3
      ]);
      latestArray = choices;
    } else {
      choices = latestArray;
    }

    return (
      <React.Fragment>
        <div className="choices">
        <div className="sentence">Q.{this.props.number + 1} {this.props.question.sentence}</div>
        <div className="choice">{this.renderChoice(choices[0])}</div>
        <div className="choice">{this.renderChoice(choices[1])}</div>
        <div className="choice">{this.renderChoice(choices[2])}</div>
        <div className="choice">{this.renderChoice(choices[3])}</div>
        </div>
      </React.Fragment>
    );
  };
}


class Course extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      courseName: this.props.courseName,              // クイズ名
      questions: nativeShuffle(this.props.questions), // 問題情報
      number: 0,                                      // 何問目か
      answering: true,                                // 回答中?
      lastQuestion: false,                            // 最後の一問?
      allFinished: false,                             // 全問おわった?
      lastestResult: null,                            // 直前の問題を正解したか
      latestChoice: null,                             // 直前の選択肢で何を選んだ?
      history: [],                                    // 回答履歴
    };
  }
  
  // 選択肢をクリックした時の操作
  clickChoice (answer, choice) {
    if (this.state.answering) {
      if (answer === choice) {
        this.setState({lastestResult: true});
      } else {
        this.setState({lastestResult: false});
      }
      // 回答中をfalseにする
      this.setState({
        answering: false,
        history: this.state.history.concat(answer === choice),
        latestChoice: choice,
      });
    } else {
      return;
    }
  }

  // 次へボタンをクリックした時の操作
  clickNext () {
    if (this.state.questions.length === this.state.number + 1) {
      this.setState({lastQuestion: true});
    }
    this.setState({
      answering: true,
      number: this.state.number + 1,
      latestChoice: null,
    })
  }
  
  render() {
    const courseName = this.state.courseName;
    const number = this.state.number;
    const question = this.state.questions[number];
    const answering = this.state.answering;
    const lastQuestion = this.state.lastQuestion;
    const lastestResult = this.state.lastestResult;
    const latestChoice = this.state.latestChoice;
    const history = this.state.history;
    
    const setQuestion = () => {
      return (
        <React.Fragment>
          <Question
          question={question}
          number={number}
          answering={answering}
          latestChoice={latestChoice}
          onClick={(a, c) => this.clickChoice(a, c)}
          />
        </React.Fragment>
      );
    }

    const setHistory = history.map((value, i) => {
      var number = i + 1;
      var correctness = value ? "O" : "X";
      return(
        <div key={number} className="history">Q{number}. {correctness}</div>
      );
    });

    const setCommentary = (commentaryColor) => {
      if (!question.commentary) {
        return (
          <div className={commentaryColor} >{question.commentary}</div>
        );
      } else {
        return (<div></div>);
      }
    }

    const generatePage = (answering, question) => {
      if (this.state.lastQuestion) {
        return(
          <Result history={history} />
        );
      } else if (answering) {
        return (
          <div className="quiz-board__main--upper">{setQuestion(question)}</div>
        );
      } else {
        if (lastestResult) {
          var commentaryColor = "blue-commentary";
        } else {
          var commentaryColor = "red-commentary";
        }
        return (
          <React.Fragment>
            <div className="quiz-board__main--upper">
              {setQuestion(question)}
              <Correctness collectness={lastestResult} />
            </div>
            <div className="quiz-board__main--lower">
              {setCommentary(commentaryColor)}
              <NextButton onClick={() => this.clickNext()} />
            </div>
          </React.Fragment>
        );
      }
    };

    return (
      <React.Fragment>
        <div className="main">
          <div className="main__content">
            <div className="quiz-board">
              <div className="quiz-board__header">
                <div className="quiz-board__header--title">
                  {courseName}
                </div>
              </div>
              <div className="quiz-board__main">
                {generatePage(answering, question, lastQuestion)}
              </div>
            </div>
          </div>
          <div className="main__sidebar">
            <div className="history-list">{setHistory}</div>
          </div>
        </div>
      </React.Fragment>
    );
  }
}

Course.propTypes = {
  questions: PropTypes.array,
  courseName: PropTypes.string,
}
export default Course